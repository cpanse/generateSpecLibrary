__author__ = 'witold'

import sys
import os
import os.path
import yaml
import re
import cakeme

import BiblioSpecLib

import cakeme.fileutils
import cakeme.applibase

def replaceUriHeader( path ):
    res = re.sub("^[a-z]+://", "", path)
    return res

def replaceUriHeader2(path):
    res = re.sub("^[a-z]+@[a-z-0-9\.]+:", "", path)
    return res

class LibraryGenerationParametersNEW:
    WORK_DIR = "."
    parameters = ''
    JOB_ID = -1
    LIST_OF_DAT_FILES = ""  # dat files to process
    RETURN_CODE = 0  # status of class, value different 1 indicates that something went wrong.
    LOCAL_WORK_DIR = os.path.join(WORK_DIR, "temp")  # where temporary results are stored.
    LOCAL_RES_DIR = os.path.join(WORK_DIR, "res")  # where results are stored
    TOP_N_TRANSITIONS = 6
    MASCOT_DATABASE_LOCATION = ""

    def check_dat_files(self):
        if len(self.LIST_OF_DAT_FILES) == 0:
            self.logger.error("No dat file list is provided")
            self.RETURN_VALUE = 1
        self.LIST_OF_DAT_FILES = [replaceUriHeader2(x) for x in self.LIST_OF_DAT_FILES]
        for file in self.LIST_OF_DAT_FILES:
            if not os.path.exists(file):
                self.logger.error("dat file can't be found " + file)
                self.RETURN_VALUE = 1

    ## TODO: rename
    def write_result_yaml(self):
        self.parameters["processed"] = "true"
        with open(os.path.join(self.LOCAL_RES_DIR, 'data.yml'), 'w') as outfile:
            outfile.write(yaml.dump(self.parameters, default_flow_style=True))

    def generate_zip(self):
        zipfile = os.path.basename(self.OUTPUT)
        self.TMP_ZIP = os.path.join(self.WORK_DIR, zipfile)
        cakeme.fileutiles.zip_dir(self.LOCAL_RES_DIR, self.TMP_ZIP)



    def set_up(self, assay_library_yaml):
        with open(assay_library_yaml, 'r') as stream:
            self.parameters = yaml.load(stream)

        self.JOB_ID = int(self.parameters["job_configuration"]["external_job_id"])
        self.LOCAL_WORK_DIR = "{}.{}".format(self.LOCAL_WORK_DIR, self.JOB_ID)

        if not os.path.exists(self.LOCAL_WORK_DIR):
            os.makedirs(self.LOCAL_WORK_DIR)
        else:
            cakeme.fileutils.remove_files_from_folder(self.LOCAL_WORK_DIR)

        self.LOCAL_RES_DIR = "{}.{}".format(self.LOCAL_RES_DIR, self.JOB_ID)
        if not os.path.exists(self.LOCAL_RES_DIR):
            os.makedirs(self.LOCAL_RES_DIR)
        else:
            cakeme.fileutils.remove_files_from_folder(self.LOCAL_RES_DIR)

        self.logger = cakeme.applibase.setUpLogging(os.path.join(self.LOCAL_RES_DIR, "fgcz_test_yaml.log"))
        self.app_parameters = self.parameters["application"]
        self.OUTPUT = replaceUriHeader2(self.app_parameters["output"][0])
        zipfile = os.path.basename(self.OUTPUT)
        self.TMP_ZIP = os.path.join(self.WORK_DIR, zipfile)
        self.LIST_OF_DAT_FILES = self.app_parameters["input"]['mascot_dat']
        self.MASCOT_DATABASE_LOCATION = self.app_parameters['parameters']['mascot_database_location']
        self.MIN_N = int(self.app_parameters['parameters']['minN'])
        self.MAX_N = int(self.app_parameters['parameters']['maxN'])
        self.MZ_ERROR = float(self.app_parameters['parameters']['mzError'])
        self.check_dat_files()


if __name__ == "__main__":
    assay_library_yaml = ""
    if len(sys.argv) == 1:
        raise Exception('No Yaml File Provided')
        sys.exit(1)
    else:
        assay_library_yaml = sys.argv[1]

    lgp = LibraryGenerationParametersNEW()
    lgp.set_up(assay_library_yaml)

    print lgp.LIST_OF_DAT_FILES, lgp.LOCAL_RES_DIR, lgp.LOCAL_WORK_DIR, lgp.TMP_ZIP, lgp.JOB_ID, \
        lgp.MASCOT_DATABASE_LOCATION, lgp.RETURN_CODE

    lgp.write_result_yaml()
    if True:
        blsl = BiblioSpecLib.BlibBuild(lgp.LIST_OF_DAT_FILES,
                                       lgp.LOCAL_RES_DIR,
                                       lgp.LOCAL_WORK_DIR,
                                       lgp.TMP_ZIP,
                                       lgp.MASCOT_DATABASE_LOCATION,
                                       lgp.MIN_N, lgp.MAX_N, lgp.MZ_ERROR)
        blsl.run()

    scp = cakeme.applibase.SCPCopy(lgp.LOCAL_RES_DIR)
    ret = scp.stageFileTo("bfabric", "fgcz-s-021", lgp.TMP_ZIP, lgp.OUTPUT )

    if lgp.RETURN_CODE != 0:
        sys.exit(lgp.RETURN_VALUE)

    #ret= scp.stageFileTo("bfabric", "fgcz-s-021", "config.365.yaml" ,"/srv/www/htdocs//p1000/bfabric/Proteomics/DIA_Assay_Library_Generator/2015/2015-10/2015-10-27//workunit_136124/206686.zip")
    #print ret