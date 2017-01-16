# cocoalima.com

This is the official repo for cocoalima website. 

## Info

Built using [Vapor](https://github.com/vapor/vapor) and deployed with [Heroku](https://www.heroku.com/).

## Specs
- Ruby 2.3
- Vapor 1.3
- PostgreSQL 9.5.4

## Running locally

Get the source

    $ git clone https://github.com/CoderPug/cocoalima.com.git

Configure your local postgresql credentials in 

    Config/secrets/postgresql.json

Following this structure

```
{
    "host": "127.0.0.1",
    "user": "coche",
    "password": "",
    "database": "mainswift",
    "port": 5432
}
```

Start the server

    $ vapor xcode

Then open <http://localhost:8080> in your browser to see it running. If you have any issues, [send me an email](mailto:torres.cardenas.jose@me.com).