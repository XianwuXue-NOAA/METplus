#! /bin/bash

pip3 install lxml
pip3 install PyMySQL

basedir=$(dirname "$0")
work_dir=$basedir/../../..

# run manage externals to obtain METdatadb
${work_dir}/manage_externals/checkout_externals -e ${work_dir}/ci/parm/Externals_metdatadb.cfg
