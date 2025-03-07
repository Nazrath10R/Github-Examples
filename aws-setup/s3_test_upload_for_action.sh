
# cp ../deprecated/example.csv ../deprecated/example2.csv
aws s3api delete-object --bucket bucket-for-github-action-nn --key example2.csv
aws s3 cp ../deprecated/data/example2.csv s3://bucket-for-github-action-nn/data/