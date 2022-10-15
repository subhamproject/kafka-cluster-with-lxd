# kafka-cluster-with-lxd

NOTE - THIS ENTIRE SETTING UP KAFKA CLUSTER WILL TAKE NEARLY 2 HOURS TO TIME AS IT WILL HAVE TO DOWNLOAD ALL THE SOFTWARES AND INSTALL - IT MAY ALSO DEPENDS ON YOUR INTERNET SPEED

This repo has all config and script to auto setup kafka cluster using LXD ubuntu 22.04


*** USAGE ***


git clone \<this repo\>

git clone https://github.com/subhamproject/kafka-cluster-with-lxd.git

![image](https://user-images.githubusercontent.com/26158459/196003393-d5592094-65a9-42cf-8e9b-54bd023eac67.png)



vagrant up && vagrant ssh

![image](https://user-images.githubusercontent.com/26158459/196003421-f6add9e1-e6a0-44ed-b619-009a3ee942b5.png)



THIS WILL CONFIGURE 6 SERVERS - 3 KAFKA AND 3 ZOOKEEPER

![image](https://user-images.githubusercontent.com/26158459/196003319-7ecb2f39-6e5a-4112-8375-c0f04de8ec59.png)


YOU CAN THEN LOGIN GO ANY CONTAINER AND RUN CREATE/COPY SCRIPT TO CREATE TOPICS

 COMMAND to login to kafka server
 
 ![image](https://user-images.githubusercontent.com/26158459/196003499-5f1e160e-a6bf-4e0b-81d4-26ce7bf1e952.png)
 
 
 ![image](https://user-images.githubusercontent.com/26158459/196003544-c08002cc-ad3b-4309-a16a-edd719c7bbe2.png)

![image](https://user-images.githubusercontent.com/26158459/196003552-1a4a67c1-afa3-4b9c-8f15-86a8f4d08921.png)
save and quit

and run

![image](https://user-images.githubusercontent.com/26158459/196003584-2b558a16-83d8-464b-942f-24a9b7270d7c.png)

 
 SIMILAR WAY YOU CAN CREATE/COPY SCRIPT WHICH IS THERE IN THIS REPO TO CREATE /LIST /DESCRIBE AND CHECK THE DATA IN TOPICS

