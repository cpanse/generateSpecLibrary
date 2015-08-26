__author__ = 'witold'

import sys
import os
import os.path
import yaml
import re


import BiblioSpecLib
def replaceUriHeader(path):
    res = re.sub("^[a-z]+://", "", path)
    return res

class LibraryGenerationParameters:
    parameters = ''
    JOB_ID = -1
    OUT_ZIP = "" # zip file to write to
    LIST_OF_DAT_FILES = "" # dat files to process
    RETURN_CODE = 0 # status of class, value different 1 indicates that something went wrong.
    LOCAL_WORK_DIR = "./temp" # where temporary results are stored.
    LOCAL_RES_DIR = "./res" # where results are stored
    TOP_N_TRANSITIONS=6
    MASCOT_DATABASE_LOCATION = ""

    def check_dat_files(self):
        if len(self.LIST_OF_DAT_FILES) == 0:
            self.logger.error("No dat file list is provided")
            self.RETURN_VALUE = 1
        self.LIST_OF_DAT_FILES = [replaceUriHeader(x) for x in self.LIST_OF_DAT_FILES]
        for file in self.LIST_OF_DAT_FILES:
            if not os.path.exists(file):
                self.logger.error("dat file can't be found " + file)
                self.RETURN_VALUE = 1

    def write_result_yaml(self):
        self.parameters["processed"] = "true"
        with open(os.path.join(self.LOCAL_RES_DIR, 'data.yml'), 'w') as outfile:
            outfile.write(yaml.dump(self.parameters, default_flow_style=True))
        path_to_zip = os.path.dirname(self.OUT_ZIP)
        if not os.path.exists(path_to_zip):
            os.makedirs(path_to_zip)
        BiblioSpecLib.zip_dir(self.LOCAL_RES_DIR, self.OUT_ZIP)


    def set_up(self, assay_library_yaml):
        with open(assay_library_yaml, 'r') as stream:
            self.parameters = yaml.load(stream)
        self.JOB_ID = int(self.parameters["bfabric_external_job_id"])
        self.LOCAL_WORK_DIR = "{}.{}".format(self.LOCAL_WORK_DIR, self.JOB_ID)

        if not os.path.exists(self.LOCAL_WORK_DIR):
            os.makedirs(self.LOCAL_WORK_DIR)
        self.LOCAL_RES_DIR = "{}.{}".format(self.LOCAL_RES_DIR, self.JOB_ID)
        if not os.path.exists(self.LOCAL_RES_DIR):
            os.makedirs(self.LOCAL_RES_DIR)
        self.logger = BiblioSpecLib.setUpLogging(os.path.join(self.LOCAL_RES_DIR, "fgcz_test_yaml.log"))

        self.OUT_ZIP = replaceUriHeader(self.parameters["output_zip"])
        self.LIST_OF_DAT_FILES = self.parameters["input_mascot_dat_file"]
        self.MASCOT_DATABASE_LOCATION = self.parameters['mascot_database_location']
        self.MIN_N = self.parameters['minN']
        self.MAX_N = self.parameters['maxN']
        self.check_dat_files()


if __name__ == "__main__":

    assay_library_yaml = ""
    if len(sys.argv) == 1:
        raise Exception('No Yaml File Provided')
        sys.exit(1)
    else :
        assay_library_yaml=sys.argv[1]

    lgp = LibraryGenerationParameters()
    lgp.set_up(assay_library_yaml)

    print lgp.OUT_ZIP , lgp.LOCAL_WORK_DIR, lgp.JOB_ID, lgp.LIST_OF_DAT_FILES, lgp.RETURN_CODE
    if True:
        blsl = BiblioSpecLib.BlibBuild(lgp.LIST_OF_DAT_FILES,
                                       lgp.LOCAL_RES_DIR,
                                       lgp.LOCAL_WORK_DIR,
                                       lgp.MASCOT_DATABASE_LOCATION,
                                       lgp.MIN_N, lgp.MAX_N)
        blsl.run()

    lgp.write_result_yaml()
    if lgp.RETURN_CODE != 0:
        sys.exit(lgp.RETURN_VALUE)





