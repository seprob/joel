# Joel

## Synopsis

Joel can be used to delete tables content from Cassandra database except system keyspaces.

## Usage

```
joel.sh -u user_name -p user_password -v cql_version -s server_address
```
where
- "user_name" (optional) is a database user,
- "user_password" (optional) is a user database password,
- "cql_version" is a remote CQL protocol version,
- "server_addres" (optiona) is a address which the server is listening on.
