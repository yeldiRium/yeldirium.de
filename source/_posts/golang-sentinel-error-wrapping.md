---
layout: post
title: GoLang Sentinel Error Wrapping
description: How to chain errors in GoLang using multiple Sentinel Errors.
date: 2024-10-10 17:39:00
tags:
  - GoLang
  - Error Handling
category:
  - development
  - GoLang
---
The GoLang error model is in my opinion one of the best around. Returning errors is a vast improvement over throwing errors. I won't go into detail on that, since there are much better write ups about that out there (e.g. [The Error Model by Joe Duffy](https://joeduffyblog.com/2016/02/07/the-error-model/)).
There are two main concepts out there when working with errors in Go: Sentinel Errors and Error Wrapping. There are various blog posts on the two topics, even a few by the [language mantainers themselves](https://go.dev/blog/go1.13-errors). A very short overview:

- Sentinel Errors are predefined errors that are exported by packages. These error values allow inspecting the returned errors from functions and reacting appropriately to specific kinds of errors.
- Error wrapping adds context to received errors and makes tracing errors sources much easier.

One use case I have not seen much debated though:

```go
// This is an example packages we're using:
var ErrGettingData = errors.New("failed to get data :/")

func GetDataFromSomewhere() data, error {
	// ...
	if /* something went wrong */ {
		return ErrGettingData
	}
	return someData
}

// This is the package we're developing ourselves:
func DoThingsWithData() error {
	data, err := GetDataFromSomewhere()
	if err != nil {
		return fmt.Errorf("failed to get data from somewhere: %w", err)
	}
	// Business logic...
}
```
If I now want to write tests for `DoThingsWithData` and check for the kind of error using `errors.Is`, I can only check for `ErrGettingData`. I am not able to check for Sentinel Errors that I have defined myself. Or am I?

I propose Sentinel Error Wrapping:
```go
var ErrGettingDataFromSomewhere = errors.New("failed to get data from somewhere")

func DoThingsWithData() error {
	data, err := GetDataFromSomewhere()
	if err != nil {
		returm fmt.Errorf("%w: %w", ErrGettingDataFromSomewhere, err)
	}
	// Business logic...
}
```
This allows checking with `errors.Is` for an `ErrGettingDataFromSomewhere` while still allowing to check for `ErrGettingData`. Best of both worlds.
