# This script basically will ping IP addresses, if it detects that one of them are down it adds them to a list of affected users, after is done pinging all the IP addresses it will send an email out alerting the recipients
# these addresses are down and will then hang and wait for user input after someone gets into the system.

# Meltdown is just a silly name I came up

# Option 1 will failover affected customers and do a curl PUT to change the IP address of all affected customers (this is horribly inefficient and every customer must have a 3 line if statement)

# Option 2 will failover all customers to their backup IP in one go without checking if their primary is even up

# Option 3 will change all customer IPs back to the main address

# Option 4 is of course to ignore the request. This is in case you had a minor power flicker or some expected downtime and don't want the IP addresses to change.
