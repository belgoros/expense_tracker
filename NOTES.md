# Development notes

## Schema and relations

The relations are pretty basic:

- there is `Category` module to contain categories of expenses, which has a one-to-many relation with `Expense` module
- there is `Expense` module which has a `belongs_to` `Category relation.

## Handling money/currency

`Decimal` was chosen as a type to contain money amounts.
No special money/currency has been implemented at this stage. One of the popular libraries should be used to manage different currencies, for example [money](https://hexdocs.pm/money/readme.html).
In this case a new migration should be added to change the existing decimal types to be integer instead. It is also possible to define a default currency to be used in the `config.exs` file.

## Architectural decisions

### Display percentage progress bar

[Chart.js](https://www.chartjs.org) library is used to display spent percentage on the Category page.
See teh declared `Hooks` for more settings details.

To limit the number of expenses to be displayed on the Category page, its default value is set in the `config.exs`. file as `expenses_per_page` entry.

A better to manage this limit would be define a drop-down list on the Category page and handle its change to display the corresponding number of Expenses per page.

Most part of the tests are unit tests cover the context module (`Budget`).
As for live view tests, only category related tests are implemented.

The preferred testing strategy being to have as many as needed models/entity unit tests and some integration ones to cover most important functionalities.
