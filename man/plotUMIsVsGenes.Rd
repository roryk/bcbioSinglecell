% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/AllGenerics.R, R/methods-plotUMIsVsGenes.R
\docType{methods}
\name{plotUMIsVsGenes}
\alias{plotUMIsVsGenes}
\alias{plotUMIsVsGenes}
\alias{plotUMIsVsGenes,SingleCellExperiment-method}
\alias{plotUMIsVsGenes,seurat-method}
\title{Plot UMI and Gene Correlation}
\usage{
plotUMIsVsGenes(object, ...)

\S4method{plotUMIsVsGenes}{SingleCellExperiment}(object, interestingGroups,
  trendline = FALSE, color = scale_color_hue(), trans = "log2",
  title = "UMIs vs. genes")

\S4method{plotUMIsVsGenes}{seurat}(object, interestingGroups,
  trendline = FALSE, color = scale_color_hue(), trans = "log2",
  title = "UMIs vs. genes")
}
\arguments{
\item{object}{Object.}

\item{...}{Additional arguments.}

\item{interestingGroups}{Character vector of interesting groups. Must be
formatted in camel case and intersect with \code{\link[=sampleData]{sampleData()}} colnames.}

\item{trendline}{Include trendline on plot.}

\item{color}{Desired ggplot color scale. Must supply discrete values. When
set to \code{NULL}, the default ggplot2 color palette will be used. If manual
color definitions are desired, we recommend using
\code{\link[ggplot2:scale_color_manual]{ggplot2::scale_color_manual()}}.}

\item{trans}{Name of the axis scale transformation to apply. See
\code{help("scale_x_continuous", "ggplot2")} for more information.}

\item{title}{Plot title.}
}
\value{
\code{ggplot}.
}
\description{
Plot UMI and Gene Correlation
}
\examples{
# SingleCellExperiment ====
plotUMIsVsGenes(cellranger_small)
}
\author{
Michael Steinbaugh, Rory Kirchner
}
