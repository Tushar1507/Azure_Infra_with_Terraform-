# Terraform_Azure_Infra

**#Please ignore the vars.tf files, as I didn't put any variables there just for making the code more understandable, defined each and every resources with proper hard coded values only but for showing the code structure, I just put vars.tf and output.tf files.**

**#Used the Paas services here for computing(forntend and backend) also, as they provide autoscaling and high availability options. Instead of web-apps we can use Virtual machines or VMSS (virtual machine scale sets) to host our frontend and backend apps, in that case we can use NSG to secure connectivity for them.**

**# Used Azure managed MySQL Server and private end point connectivity between DB and backned as well as between backend and frontend.**
