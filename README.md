# Craigslist Alert

Craigslist Alert is a service that monitors CL listings and texts you of any posts that meet your interests. Receiving notifications reduces time spent browsing Craigslist, and enables you to be the first to respond.

## Dependencies

- [Elixir](https://elixir-lang.org/)
- [Redis](https://redis.io/)
- [Twilio](https://www.twilio.com/) account for sending SMS

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
{"items":
  [
    {"keywords": ["king", "downsizing"], "category": "fua", "city": "portland"},
    {"keywords": ["macbook", "dock"], "category": "syp", "city": "portland", "max_price": 55, "min_price": 3},
    {"category": "sss", "city": "portland", "keywords": ["vanity table", "mirror"]}
  ]
}
```

Required fields: keywords, category, city

You can determine CL categories via URLs in craigslist search, or from [this gist](https://gist.github.com/flodel/2573531#file-pick-category-r)


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

### Unfrequently asked questions (UAFs)
Q. Why?
> I was moving and needed a lot of furniture. I didn't want to spend time regularly checking Craigslist. Also, I wanted to learn how to send texts with Twilio.

Q. What is "Clex"?
> I see it's common for some people to start or end with "Ex" for "Elixir." So it is..was..."CLex". Not my best moment.

Q. What's next?
> I really wanted to write an auto-haggler (via email or text). I tried for a day but couldn't find a way around Google's Recaptcha (not for free, at least).

## Todo
1. refactor Periodically
2. additional filters (e.g. 2mi from zipcode, 3BR house, has image)
3. move from SmsBlitz to ex_twilio
4. remove dependency on Redis / pure Elixir.
5. Option to notify via email (mailgun) and/or text
6. Auto-email the poster
   - Need browser that can execute Javascript (Wallaby/PhantomJS and Hound/Chrome driver both worked)
   - issue right now is tricking Recaptcha
   - possibly cookie-related
   - once Recaptcha thinks I am not a bot, we can retrieve the email