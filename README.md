# Banking Api


## Description

> This project is part of the Stone Banking API challenge


### Table of Contents

- [Banking Api](#banking-api)
  * [Description](#description)
    + [Table of Contents](#table-of-contents)
  * [Running Project](#running-project)
  * [Endpoints](#endpoints)
    + [1. Create User and Account](#1-create-user-and-account)
      - [Success Response](#success-response)
      - [Error Responses](#error-responses)
    + [2. Withdrawal](#2-withdrawal)
      - [Success Response](#success-response-1)
      - [Error Responses](#error-responses-1)
    + [3. Transfer funds between accounts](#3-transfer-funds-between-accounts)
      - [Success Response](#success-response-2)
      - [Error Responses](#error-responses-2)
    + [4. Retrive account balance](#4-retrive-account-balance)
      - [Success Response](#success-response-3)
      - [Error Responses](#error-responses-3)
  * [Model](#model)
    + [Tables](#tables)


## Running Project

To run the project you need first to have a Postgres container running on port 5432.

``` sh
# Run this to have a database on 5432
docker-compose up -d
```


To configure the database and download the dependencies: 

``` sh
# On the root folder
mix setup
```

To run tests: 

``` sh
# On the root folder
mix test
```

To serve the application:

``` sh
# On the root folder. By default it runs at `4000` port.
mix phx.server
```


## Endpoints

### 1. Create User and Account

Create an User and Account

**URL** : `/api/user/`

**Method** : `POST`


 All fields must be sent.

```json
{
    "name": "[unicode 64 chars max]",
    "cpf": "[11 chars, only numbers]",
    "email": "[xxx@xxx.xxx]" 
}
```



#### Success Response

**Condition** : If everything all inputs are valid and there is no duplication.

**Code** : `201 CREATED`

**Payload example**

```json
{
  "description": { 
    "account_id": "5cd5e558-a8e3-4f5f-9695-758eb5604b0b",
    "cpf": "65054866882",
    "email": "example@email.com",
    "id": "6300eb44-87e4-4674-b3b4-fd322c8479f6",
    "name": "Name",
    "balance": "Your actual balance is $1000.00"
  }
}
```

#### Error Responses

**Code** : `400 BAD REQUEST`

**Content example**

```json
{
  "description": {
    "email": "has already been taken"
  },
  "type": "bad_input"
}
```




### 2. Withdrawal

Create an User and Account

**URL** : `/api/account/withdrawal`

**Method** : `POST`


 All fields are required and the value must be in cents.

```json
{
	"id": "[Valid UUID. Ex: 5cd5e558-a8e3-4f5f-9695-758eb5604b0b]",
	"withdrawal": "[integer value]"
}
```



#### Success Response

**Condition** : If the account and the the value are valid.

**Code** : `201 CREATED`

**Payload example**

```json
{
  "description": "Your actual balance is $994.32"
}
```

#### Error Responses

**Code** : `400 BAD REQUEST`

**Content example**

```json
{
  "withdrawal": "can't be blank"
}
```

or 

```json
{
  "description": "Invalid Id",
  "type": "bad_input"
}

```


### 3. Transfer funds between accounts

Create an User and Account

**URL** : `/api/account/transfer`

**Method** : `POST`


 All fields are required and the value must be sent in cents.

```json
{
	"origin": "[Valid UUID. Ex: 5cd5e558-a8e3-4f5f-9695-758eb5604b0b]",
	"destiny": "[Valid UUID. Ex: 5cd5e558-a8e3-4f5f-9695-758eb5604b0b]",
	"value": "[integer]"
}
```


#### Success Response

**Condition** : If the accounts and the value are valid.

**Code** : `201 CREATED`

**Payload example**

```json
{
  "description": "Your actual balance is $994.32"
}
```

#### Error Responses

**Code** : `400 BAD REQUEST`

**Content example**

```json
{
  "description": {
    "value": "can't be blank"
  },
  "type": "bad_input"
}
```

or 

```json
{
  "description": {
    "id": "is invalid"
  },
  "type": "bad_input"
}v

```


**Code** : `404 BAD REQUEST`

```json
{
  "description": "Account not found",
  "type": "not_found"
}
```

### 4. Retrive account balance

Recovers current account balance


**URL** : `/api/account/:id`

**Method** : `GET`

        

#### Success Response

**Condition** : If the account is correct.

**Code** : `200 OK`

**Payload example**

```json
{
  "description": "Your actual balance is $994.32"
}
```

#### Error Responses

**Code** : `400 BAD REQUEST`

**Content example**

```json
{
  "description": "Invalid Id",
  "type": "bad_input"
}
```



**Code** : `404 BAD REQUEST`

```json
{
  "description": "Account not found",
  "type": "not_found"
}
```



## Model



### Tables


##### Users

Column | Type | Mandatory 
------------- | -------------|-------------
id  | uuid | X
email  | string | X
name| string | X
cpf  | string | X
inserted_at  | timestamp | X
updated_at  | timestamp | X



##### Accounts

Column | Type | Mandatory 
------------- | -------------|-------------
id  | uuid | X
balance  | integer | X
user_id| uuid | X
inserted_at  | timestamp | X
updated_at  | timestamp | X


##### Transactions

Column | Type | Mandatory 
------------- | -------------|-------------
id  | uuid | X
external  | boolean | X
value | integer | X
transaction_id | uuid | 
account_id  | timestamp | X
inserted_at  | timestamp | X

