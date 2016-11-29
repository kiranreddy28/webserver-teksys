# webserver-teksys
The main aim of the project is to create the web server that is scalable ad available.
Configuration management is done by using Chef-Solo, Chef Kitchen is used to automate the testing of server configuration. 
Chef-solo cookbooks are uploaded to the s3 bucket and orchestarted with the cloudformation template.
CloudFormation Template is created to put the infrastrucure as code.
Cloudformation Stack is initiated and monitored using helper scripts and AWS CloudWatch.
Self-signed certificate is used to secure the webserver application
