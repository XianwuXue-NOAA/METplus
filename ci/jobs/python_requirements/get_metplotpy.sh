#! /bin/bash

pip3 install matplotlib
pip3 install scipy
pip3 install cmocean
pip3 install plotly==4.9.0
pip3 install kaleido

basedir=$(dirname "$0")
work_dir=$basedir/../../..

# run manage externals to obtain METcalcpy
${work_dir}/manage_externals/checkout_externals -e ${work_dir}/ci/parm/Externals_metplotpy.cfg

pip3 install ${work_dir}/../METplotpy
