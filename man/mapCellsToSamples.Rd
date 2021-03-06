% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/mapCellsToSamples.R
\name{mapCellsToSamples}
\alias{mapCellsToSamples}
\title{Define Cell to Sample Mappings}
\usage{
mapCellsToSamples(cells, samples)
}
\arguments{
\item{cells}{Cell identifiers.}

\item{samples}{Sample identifiers.}
}
\value{
Named \code{factor} containing cells as the names, and samples as the
factor levels.
}
\description{
This function extracts \code{sampleID} from the \code{cellID} column using grep
matching.
}
\examples{
# bcbioSingleCell ====
object <- indrops_small

cells <- colnames(object)
glimpse(cells)

# Use the sample ID for the mappings, which must be present in the cell ID
sampleNames(object)
samples <- names(sampleNames(object))
# samples <- rownames(sampleData(object))
samples

# Sample ID must be the prefix of the cell IDs
stopifnot(all(grepl(paste0("^", samples[[1]]), cells)))

x <- mapCellsToSamples(cells = cells, samples = samples)
glimpse(x)
}
\seealso{
Other Data Functions: \code{\link{aggregateReplicates}},
  \code{\link{cell2sample}}, \code{\link{fetchGeneData}},
  \code{\link{metricsPerSample}}, \code{\link{sampleData}},
  \code{\link{selectSamples}},
  \code{\link{subsetPerSample}}, \code{\link{topBarcodes}}
}
\author{
Michael Steinbaugh
}
