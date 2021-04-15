# Banking Api


> This project is part of the Stone Banking API challenge

To run the project you need first to have a Postgres container running on port 5432.

``` sh
# Run this to have a database on 5432
docker-compose up -d
```

To run tests: 

``` sh
# On the root folder
mix test
```

To run the application:

``` sh
# On the root folder. By default it runs at `4000` port.
mix phx.server
```



# Endpoints

## 1. Create User and Account

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



### Success Response

**Condition** : If everything all inputs are valid and there is no duplication.

**Code** : `201 CREATED`

**Payload example**

```json
{
  "account_id": "5cd5e558-a8e3-4f5f-9695-758eb5604b0b",
  "cpf": "65054866882",
  "email": "example@email.com",
  "id": "6300eb44-87e4-4674-b3b4-fd322c8479f6",
  "name": "Name",
  "balance": "Your actual balance is $1000.00"
}
```

### Error Responses

**Code** : `400 BAD REQUEST`

**Content example**

```json
{
  "email": "has already been taken"
}
```




## 2. Withdrawal

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



### Success Response

**Condition** : If the account and the the value are valid.

**Code** : `201 CREATED`

**Payload example**

```json
{
  "balance": "Your actual balance is $994.32"
}
```

### Error Responses

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


## 3. Transfer funds between accounts

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


### Success Response

**Condition** : If the accounts and the value are valid.

**Code** : `201 CREATED`

**Payload example**

```json
{
  "balance": "Your actual balance is $994.32"
}
```

### Error Responses

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


**Code** : `404 BAD REQUEST`

```
{
  "description": "Account not found",
  "type": "not_found"
}
```

## 4. Retrive account balance

Recovers current account balance


**URL** : `/api/account/:id`

**Method** : `GET`

        

### Success Response

**Condition** : If the account is correct.

**Code** : `200 OK`

**Payload example**

```json
{
  "balance": "Your actual balance is $994.32"
}
```

### Error Responses

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