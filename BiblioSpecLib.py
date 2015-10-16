from cakeme.applibase import ApplicationBase
from cakeme.applibase import ProcessValues
import os
import shutil
import cakeme
import re
import sys

def get_db_from_mascot_dat(file):
    with open(file, "r") as f:
        for line in f:
            m = re.match('^release=*',line)
            if m:
                found = re.search('^release=(.+\.fasta$)',line)
                if found:
                    return found.group(1)

class SCPCopy(ApplicationBase):
    def copyDatFiles(self, source_computer, files2move, destination_directory):
        if os.path.exists(destination_directory):
            shutil.rmtree(destination_directory)

        if not os.path.exists(destination_directory):
            os.makedirs(destination_directory)

        for dat_file in files2move:
            dat_file.strip()
            if dat_file[0] != "#":
                scp_command = "scp {}:{} {}".format(source_computer,
                                               dat_file.strip(),
                                               os.path.join(destination_directory,
                                               os.path.basename(dat_file)))
                self.logger.info("Run : {}".format(scp_command))
                self.executeCommand(scp_command)

class BlibBuild(ApplicationBase):
    PATH_2_BIBLIOSPEC = "/home/wolski/bin/BiblioSpec"
    BLIB_BUILD = "BlibBuild"
    BLIB_FILTER = "BlibFilter"
    BLIB_FILE_REDUNDANT = "blib.blib.db"
    BLIB_FILE_FILTERED = "blib.blib.filtered.db"
    MASCOT_DATABASE_LOCATION = ""
    MASCOT_DATABASE = ""
    MAX_N = 6
    MIN_N = 6

    mascot_dat_files = []

    def __init__(self, mascot_dat_files,
                 result_dir, work_dir, mascot_database_location,
                 minN, maxN, mzError):
        ApplicationBase.__init__(self, "BlibBuild", result_dir)
        self.mascot_dat_files = mascot_dat_files
        self.RESULT_DIR = result_dir
        self.WORK_DIR = work_dir
        self.MASCOT_DATABASE_LOCATION = mascot_database_location
        self.MIN_N = minN
        self.MAX_N = maxN
        self.MZ_ERROR = mzError

    def get_mascot_databases(self):
        databases = []
        for datfile in self.mascot_dat_files:
            res = get_db_from_mascot_dat(datfile)
            res = cakeme.fileutils.find_file(res, self.MASCOT_DATABASE_LOCATION)
            databases.append(res)
        databases = list(set(databases))
        if len(databases) > 1:
            warning = "Dat files where searched against various databases : {}".format(databases)
            self.RESULT = ProcessValues(0, warning, "")
            self.logger.warning(warning)
        if len(databases) == 0:
            error = "No database found!"
            self.RESULT = ProcessValues(1, "", error)
            self.logger.error(error)
            raise SystemError(error)
        return databases[0]

    def run_blib_build(self, mascot_dat_files, destination_blib):
        mascot_dat_files = " ".join(mascot_dat_files)
        blib_build = os.path.join(self.PATH_2_BIBLIOSPEC, self.BLIB_BUILD)
        blib_command = "{0} {1} {2}".format(blib_build, mascot_dat_files, destination_blib)
        self.executeCommand(blib_command)
        if self.RESULT.return_code != 0:
            raise SystemError("Return code of Command {} is not as expected : {}".format(blib_command, self.RESULT.return_code))

    def run_blib_filter(self, input_blib, output_blib):
        blibfilter = os.path.join(self.PATH_2_BIBLIOSPEC, self.BLIB_FILTER)
        blib_command = "{0} {1} {2}".format(blibfilter, input_blib, output_blib)
        self.executeCommand(blib_command)
        if self.RESULT.return_code != 0:
            raise SystemError("Return code of Command {} is not as expected : {}".format(blib_command, self.RESULT.return_code))

    def run_specL(self, fasta_file, mzError, minN, maxN, redundant_blib, filtered_blib ):
        specL_command = "./runSpecLRmd.R {0} {1} {2} {3} {4} {5} {6} {7}".format(self.RESULT_DIR, self.WORK_DIR, fasta_file,
                                                                       mzError, minN, maxN, redundant_blib, filtered_blib)
        self.executeCommand(specL_command)
        if self.RESULT.return_code != 0:
            raise SystemError("Return code of Command {} is not as expected : {}".format(specL_command, self.RESULT.return_code))

    def run(self):
        self.MASCOT_DATABASE = self.get_mascot_databases()
        redundant_blib_file = os.path.join(self.WORK_DIR,  self.BLIB_FILE_REDUNDANT)
        self.run_blib_build( self.mascot_dat_files, redundant_blib_file)
        self.logResults()
        filtered_blib_file = os.path.join(self.WORK_DIR,  self.BLIB_FILE_FILTERED)
        self.run_blib_filter( redundant_blib_file, filtered_blib_file)
        self.logResults()
        self.run_specL(self.MASCOT_DATABASE, self.MZ_ERROR, self.MIN_N, self.MAX_N, self.BLIB_FILE_REDUNDANT, self.BLIB_FILE_FILTERED)
        self.logResults()
        return self.RESULT.return_code

#class SpecLApplication(ApplicationBase):
if __name__ == "__main__":
    datfile = sys.argv[1]
    res = get_db_from_mascot_dat(datfile)
    print res
    res = cakeme.fileutils.find_file(res, "/usr/local/mascot/sequence/")
    print res