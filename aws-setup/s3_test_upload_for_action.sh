# aws s3api delete-object --bucket bucket-for-github-action-nn --key example2.csv

cd /mnt/c/Users/naz/Documents/Github-Examples/
cp deprecated/data/example.csv deprecated/data/example10.csv

aws s3 cp deprecated/data/example10.csv\
 s3://bucket-for-github-action-nn/data/

aws logs describe-log-groups --region eu-west-2