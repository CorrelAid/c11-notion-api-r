Track 3 | Challenge: Notion Wrapper for R
================


# Setup

## Dependencies

install `renv`:

```
install.packages("renv")
```

### Install/update dependencies
```
renv::restore()
```

### Adding new dependencies
1. install package as usual (with `install.packages`)
2. run `renv::snapshot()`
3. commit and push the updated `renv.lock`

## Notion
First of all, you also need a Notion workspace and have to be the admin of it. Therefore, just create a Notion account and a workspace [here](notion.so/). Having done that, you can create an access token via creating an integration [here](https://www.notion.com/my-integrations). You can find a very detailed information on how to get started with Notion integrations [here](https://developers.notion.com/docs/getting-started) as well. 


# Current functions/implementation
- `get_api_path()`: pass a notion url to the function to get the url path which has to be passed to query the API
- `NotionClient`: object-oriented approach to set up a Notion client to get the content and information from Notion for the url which was returned by get_api_path()

# TO DOs
- [ ] parse function for each data type
  - [ ] pages
  - [ ] blocks: headings etc.
  - [ ] databases: does not work with the NotionClient yet
- [ ] check nesting options
- [ ] edge cases for get_api_path()
- [ ] plain text vs formatted text

