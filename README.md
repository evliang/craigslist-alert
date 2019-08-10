# Craigslist Alert is a service that...

...monitors Craigslist and texts you of any listings that meet your interests. I created it a year ago when I moved and needed a lot of furniture, and I still use it to get notified of all kinds of electronics, toys, gadgets and random other items. For me, it alerts me to deals/items that I seek, enables me to act quickly, and saves me from wasting too much time on Craigslist.

## Dependencies
There are three dependencies you need to set this up on your own machine:
- [Elixir](https://elixir-lang.org/) environment. It's viewed by most as "the next Ruby" but I think of it more as "the next Python"
- [Redis](https://redis.io/) for caching
- [Twilio](https://www.twilio.com/) account for sending SMS. The trial account I created lasted me a year's worth of texts

## The Code

If you are interested in learning Elixir, I think that this may a good application to peruse. The domain is simple enough to focus on the components and the big picture.

But here's a quick intro for where to start:
- parser.ex takes the configuration file (discussed next) and turns it into a more computer-friendly format
- notifier.ex sends you the text (todo: email)
- storer.ex keeps tabs on previously-seen items, in order to prevent duplicate notifications, and prevent initial flooding of texts when adding new items-to-monitor to the config
- periodically.ex is the heartbeat of the application

I hope you find this code easy to read despite being new to Elixir. Let me know if you have any questions that I can answer.

## Configuration

1. Configuration is done with a JSON file

Required fields: keywords, category, city
Optional fields: min_price, max_price

An example of a configuration file:
```
{"items":
  [ 
    {"keywords": ["iPhone", "8 plus", "64GB", "-sprint", "-verizon"], "category": "sss", "city": "portland", "min_price": 300, "max_price": 380},
    {"keywords": ["iPhone", "8 plus", "64GB", "unlocked"], "category": "sss", "city": "portland", "min_price": 300, "max_price": 380},
    {"keywords": ["iPhone", "8 plus", "64GB", "T-Mobile"], "category": "sss", "city": "portland", "min_price": 300, "max_price": 380},
    {"keywords": ["lexus", "rx", "350", "2016", "-McLoughlin Chevrolet"], "category": "cta", "city": "portland", "min_price": 30000, "max_price": 39000},
    {"keywords": ["king", "downsizing"], "category": "fua", "city": "portland"},
    {"keywords": ["macbook", "dock"], "category": "syp", "city": "portland", "max_price": 55, "min_price": 5},
    {"category": "sss", "city": "portland", "keywords": ["steelcase", "leap", "-Liquidations"], "max_price": 200}
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
  has image
  title only
  miles from zip
  email, text or both
  allow multiple categories
send email (via mailgun)
code to easily query Redis for most-recent data
refactor
Redis => ETS?
scale?