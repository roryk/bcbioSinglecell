% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/methods-seurat-bcbio.R
\docType{methods}
\name{bcbio}
\alias{bcbio}
\alias{bcbio,seurat-method}
\alias{bcbio<-,seurat-method}
\title{Additional bcbio Run Data Accessor}
\usage{
\S4method{bcbio}{seurat}(object, slot)

\S4method{bcbio}{seurat}(object, slot) <- value
}
\arguments{
\item{object}{Object.}

\item{slot}{Slot name of data inside accessor.}

\item{value}{Object to assign.}
}
\value{
Various data types.
}
\description{
Additional bcbio Run Data Accessor
}
\examples{
# seurat ====
names(bcbio(seurat_small))

# Assignment method support
bcbio(seurat_small, "metadata")[["stash"]] <- "XXX"
bcbio(seurat_small, "metadata")[["stash"]]
}
\author{
Michael Steinbaugh
}
\keyword{internal}
