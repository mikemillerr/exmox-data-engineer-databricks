# Data Engineer Task — Databricks
Welcome to the next step of your conversation with exmox.

This one runs on Databricks, because that is where our platform lives and a large part of the job is knowing what the platform does for you and what it quietly does not. It is not a volume exercise. The dataset is small enough that a laptop would cope, so nothing here rewards a big cluster.

**Time budget: 3 hours.** You have a week to find them. Stop at the limit.

The task has a core and a set of deeper questions. Do the core properly first. The deeper questions are where experience shows, and we do not expect everyone to answer all of them — two of them thought through beats five skimmed. Where you are reasoning rather than recalling, mark it as such. That is a real answer here and costs you nothing; an assured one that falls apart in the follow-up session costs you a lot.
[understand the this section]

## Your environment

If you have a Databricks workspace you can use, use it. Otherwise sign up for [Databricks Free Edition](https://www.databricks.com/learn/free-edition) — it is free, takes a few minutes, and gives you serverless compute, Unity Catalog and notebooks, which is everything this task needs.

Tell us which one you used. If a limit of the free tier forced a decision you would have made differently on a real workspace, say so — that is a useful answer, not an excuse.

## The data

`data/` holds four CSVs from a rewarded-offer platform. Users install our app, browse offers, start them, reach a goal in the advertised game, and get paid a reward. The reward is our cost; we earn from the advertiser.
[Visualize as diagram, understand what to optimize for. Understand we which data is produced/comming from.]

| File | Grain | Notes |
|---|---|---|
| `installs.csv` | one row per user | acquisition attributes, `install_ts` |
| `events.csv` | one row per event | `app_open`, `offer_view`, `offer_start`, `goal_reached`, `reward_paid` |
| `offers.csv` | one row per offer | category, payout type, payout in EUR |
| `user_profile.csv` | one row per user | lifetime aggregates as our backend currently serves them |


`events.csv` has both an `event_ts` (when it happened on the device) and an `ingest_ts` (when it landed in our system).

This is synthetic data generated for this exercise. It is not exmox production data, so you can put it anywhere you like.

## The core

**1. Land it and layer it.** Get the four files into Unity Catalog and build up to a gold table that gives us, per day, per country, per platform: installs, unique users per event type, reward payouts, and reward cost in EUR. How many layers you use is your call — tell us why you drew the lines where you did.
[create catalog, schema, external volumen. Place csv in separate folders, use dlt or spark.read.stream with autoloader to read data with checkpointing, bronze ingest raw, silver cleaned(dedubed, removed possible errounous data, scd2 historized), gold aggregates, do all in dbt, use snapshots]

**2. Make it re-runnable.** Running your pipeline twice must not change the result. Running it for a single day must not require reprocessing everything. Tell us how you got there and what it cost you.
[use dbt snapshots and autoloader/dlt]

**3. Decide what is trustworthy.** The data is not clean. We are not going to tell you where. Every call you make about what to drop, fix, or keep as-is belongs in your write-up with the reason — including the ones you decided to leave alone.
[]

**4. Tests.** Write the test that would fail if your logic were wrong, not the one that confirms it is right. If you use a platform feature to enforce a rule rather than writing a test for it, say which and why that is enough.


## The deeper questions

**The daily job.** Suppose this runs at 00:15 every night over the previous calendar day. Look at `ingest_ts` before you answer. What does that job get wrong, how would you find out, and what would you build instead?

**Your platform choices.** Pick the decisions you think mattered most and defend them. What you partitioned or clustered on and how you would know if you were wrong. Which ingestion pattern you chose and where it stops being the right one. What you would govern centrally in Unity Catalog rather than leave to whoever writes the next pipeline. We are not looking for the feature list — we are looking for the trade-off you were aware of when you chose.

**How it fails.** Not how it works. Trace the ways your pipeline produces a wrong number rather than an error, and say under which conditions. Include the failure modes the platform hides from you.

**Scale.** The same shape of data now arrives from 50 sources instead of 4 files, continuously rather than as a dump. What in your design survives that, and what do you throw away?

## What to write

A `SOLUTION.md`, kept short. How to run it and how to verify it, enough that we could follow it in our own workspace, including the output of whatever convinced you it was right. What you found in the data and what you did about it — this is the section we read most carefully. Then the deeper questions you took on.

**How you worked with AI.** Which tool you used, what you asked for, what you kept, what you rejected and why. We are interested in your judgement about the output, not in your prompts — where it was confidently wrong and how you caught it is the part we read. If you run several pieces of work in parallel, or carry context between sessions, tell us how. Use whatever you normally use; we are not scoring the brand. This section is required.

## Submission

Send back an archive with your notebooks or code and `SOLUTION.md`, or a link to a repository. A workspace link on its own is not enough, since we cannot open yours.

We will go through your decisions together in the following session, and we will push back on some of them, which is the point rather than a trap.
