# Purpose and Origin of this Application

There was a time when I needed items to furnish an Airbnb. I grew frustrated with missing out on good deals on nice furniture, but did not wish to browse Craigslist multiple times a day.

So I created a service to send me a text whenever a CL post matches my interests.

A year later, I still use this application to get notified of electronics, toys and all kinds of gadgets. It alerts me to deals that I seek, enables me to act quickly, and saves me from wasting time on Craigslist. I hope that you can make use of this as well.

## Dependencies

There are three dependencies you need to set this up on your own machine:
- [Elixir](https://elixir-lang.org/install.html#distributions) environment. It's considered to be "the next Ruby" but I view it more as "the next Python"
- [Redis](https://redis.io/download) for in-memory database
- [Twilio](https://www.twilio.com/try-twilio) account for sending SMS. The trial account that I created lasted me 11 months

## The Code

If you are interested in learning Elixir, this may be a good application to peruse. The domain is simple enough to focus on the components and the big picture.

Here's a quick overview of the main modules:
- parser.ex takes the configuration file (discussed next) and turns it into a more computer-friendly format
- downloader.ex and extractor.ex fetch and transform the relevant Craigslist posts
- storer.ex keeps tabs on previously-seen items. This is for handling new config entries, and for preventing duplicate notifications
- notifier.ex sends the text
- periodically.ex is the heartbeat of the application

I hope you find this code easy to read despite being new to Elixir. Let me know if you have any questions that I can answer.

## Configuration

1. Configuration is done with a JSON file

Required fields: keywords, city
Optional fields: category, min_price, max_price, postal, search_distance, titleOnly, hasPic

An example of a configuration file:
```
{"items":
  [ 
    {"keywords": ["iPhone", "8 plus", "64GB", "unlocked"], "city": "portland", "min_price": 300, "max_price": 380},
    {"keywords": ["iPhone", "8 plus", "64GB", "T-Mobile"], "city": "portland", "min_price": 300, "max_price": 380},
    {"keywords": ["lexus", "rx", "350", "2016"], "category": "cta", "city": "portland", "min_price": 30000, "max_price": 39000, "titleOnly": true, "postal": 97204, "search_distance": 90},
    {"city": "portland", "category": "fua", "keywords": ["king", "downsizing"]}
  ]
}
```

You can determine CL categories via URLs in craigslist search, or from [this gist](https://gist.github.com/flodel/2573531#file-pick-category-r)
Otherwise, "sss" is the default category for craigslist search

2. Before running, create a `.env` file with the following lines:

```
export TWILIO_SID=[twilio sid]
export TWILIO_AUTH=[twilio auth]
export TWILIO_SENDER=[twilio sender phone #]
export TWILIO_RECIP=[twilio recipient phone #]
export CL_FILE=[name of your config file]
```

Then run:
```bash
source .env
```

## Development
```bash
mix deps.get
iex -S mix
```

## Production
```bash
mix deps.get
elixir --detached -S mix run --no-halt
```

## Backlog
send confirmation text when new items are added to the config
config (optional, per-listing):
  email, text or both
  allow multiple categories
send email (via mailgun)
code to easily query Redis for most-recent data
refactor
Redis => ETS?
scale?

8501 NE 60th St