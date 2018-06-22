# CLex

CLex is a service that monitors and texts you about recent Craigslist listings that meet your interests. Receiving notifications reduces time spent on Craigslist, and enables you to be the first to respond.

## Dependencies

You need Elixir and Redis installed on your machine. You will also need a Twilio number that can send SMS.

## Configuration

Before running, create a `.env` file with the following lines:

```
export TWILIO_SID=[twilio sid]
export TWILIO_AUTH=[twilio auth]
export TWILIO_SENDER=[twilio sender phone #]
export TWILIO_RECIP=[twilio recipient phone #]
export CL_FILE=[craigslist file location -- see below]
```

Then run:
```bash
source .env
```

4. You will need to create a JSON file (referenced above) to define the items you are interested in. Example below:

```
{"items": [
        {"keywords": ["king", "downsizing"], "category": "fua", "city": "portland"},
        {"keywords": ["macbook", "dock"], "category": "syp", "city": "portland", "max_price": 55, "min_price": 3}
]}
```

Required fields: keywords, category, city

You can determine CL categories via URLs in craigslist search, or here: https://gist.github.com/flodel/2573531#file-pick-category-r


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

## Todo
1. split up periodically
2. additional filters e.g. 3BR houses
3. remove dependency on Redis / pure Elixir1. Option to notify via email (mailgun) and/or text
4. Auto-email the poster
  --Need browser that can execute Javascript
  ----Wallaby/PhantomJS and Hound/Chrome driver both worked
  --issue right now is tricking Recaptcha
  --possibly cookie-related
  --when Recaptcha thinks I am not a bot, we can retrieve the email
5. less customized to my current needs