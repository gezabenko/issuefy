# Issuefy

issuefy is a redmine plugin for creating issues or time entries from a spreadsheet file.

##  Installation

0. `$ cd /path/to/redmine/plugins/`
1. `$ git clone https://github.com/tchx84/issuefy.git`
2. `$ bundle install --without development test`
3. restart your webserver.

> The $ sign is the consol prompt, not the command parts.

## Usage

0. Assign the _"issuefy"_ permission to the roles you seem fit.
1. Users with the corresponding roles will see the _"issuefy"_ tab in projects view.

## Spreadsheet format

### IssueFy

0. tracker name (**mandatory**)
1. assignee login name or group name
2. subject (**mandatory**, please read notes below)
3. description
4. start date (_dd/mm/yyyy_)
5. due date
6. estimated time
7. parent issue id or subject

### TimeFy

0. Issue number (**mandatory**)
1. Date (**mandatory**): _dd/mm/yyyy_
2. Hours (**mandatory**)
3. Comment

check the `example/issuefy-book.xls` and `example/timefy-book.xls` for more details about the format.

## Features

* create or update issues or time entries in your project, from a spreadsheet.
* english, spanish, german, french and simplified chinese locales.
* support for redmine 2.3.x and 2.4.x.

## Important notes

* _Issuefy_ assumes that issues subjects are unique, within the same project.
* _Issuefy_ subject uniqueness is not enforced by redmine, so use this plugin carefully.
* You have been warned.

## Collaborating

* take a look at the TODO part.
* send a message to @tchx84 / @gezabenko or just drop a pull request, through github.

## TODO

- [ ] support dynamic spreadsheet formats
- [X] load spreadsheet gem properly
- [X] redirect pages properly
- [ ] write tests
- [ ] activity
- [ ] other person behalf 