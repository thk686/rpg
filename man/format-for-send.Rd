% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/RcppExports.R, R/utils.R
\name{register_return_formatter}
\alias{register_return_formatter}
\alias{format_for_send}
\title{Convert R objects to strings}
\usage{
register_return_formatter(pgoid, f)

format_for_send(obj)
}
\arguments{
\item{pgoid}{the PostgreSQL type Oid}

\item{f}{a function}

\item{obj}{any object}
}
\description{
Prepare R objects for sending to postgresql
}
\details{
The function f must accept a vector of character values and return
a vector of values formated appropriately.

R objects that will be written to postgresql must be converted to
characters as all data is transferred to the server as text. The S3 method
\code{foramt_for_send} accomplishes this. It accepts any object and returns
a character representation.

You can define new conversions by supplying your own S3 override of
\code{format_for_send}.
}
