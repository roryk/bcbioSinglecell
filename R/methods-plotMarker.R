#' Plot Cell-Type-Specific Gene Markers
#'
#' @description
#' Plot gene expression per cell in multiple formats:
#'
#' 1. [plotMarkerTSNE()]: t-SNE gene expression plot.
#' 2. [plotDot()]: Dot plot.
#' 3. [plotViolin()]: Violin plot.
#'
#' @section Plot top markers:
#' The number of markers to plot is determined by the output of the
#' [topMarkers()] function. If you want to reduce the number of genes to plot,
#' simply reassign first using that function. If necessary, we can add support
#' for the number of genes to plot here in a future update.
#'
#' @name plotMarker
#' @family Clustering Functions
#' @author Michael Steinbaugh, Rory Kirchner
#'
#' @inheritParams general
#' @param markers `grouped_df` of marker genes.
#'   - [plotTopMarkers()]: must be grouped by "`cluster`".
#'   - [plotKnownMarkersDetected()]: must be grouped by "`cellType`".
#'
#' @return Show graphical output. Invisibly return `ggplot` `list`.
#'
#' @examples
#' object <- seurat_small
#' title <- "mito genes"
#' genes <- grep("^MT-", rownames(object), value = TRUE)
#' print(genes)
#'
#' # t-SNE
#' plotMarkerTSNE(
#'     object = object,
#'     genes = genes,
#'     title = title
#' )
#'
#' # Dark mode
#' plotMarkerTSNE(
#'     object = object,
#'     genes = genes,
#'     dark = TRUE,
#'     title = title
#' )
#'
#' # Number cloud
#' plotMarkerTSNE(
#'     object = object,
#'     genes = genes,
#'     pointsAsNumbers = TRUE,
#'     title = title
#' )
#'
#' # UMAP
#' plotMarkerUMAP(
#'     object = object,
#'     genes = genes,
#'     title = title
#' )
#'
#' # Top markers
#' markers <- topMarkers(all_markers_small, n = 1)
#' markers
#' plotTopMarkers(object, markers = tail(markers, 1))
#'
#' # Known markers detected
#' markers <- head(known_markers_small, n = 1)
#' markers
#' plotKnownMarkersDetected(object, markers = head(markers, 1))
NULL



# Constructors =================================================================
# Strip everything except the x-axis text labels
.minimalAxis <- function() {
    theme(
        axis.line = element_blank(),
        # axis.text.x = element_blank(),
        axis.text.y = element_blank(),
        axis.ticks = element_blank(),
        axis.title.x = element_blank(),
        axis.title.y = element_blank(),
        legend.position = "none",
        panel.grid = element_blank(),
        title = element_blank()
    )
}



# Dimensionality reduction (t-SNE, UMAP) plot constructor
.plotMarkerReduction <- function(
    object,
    genes,
    reduction = c("TSNE", "UMAP"),
    expression = c("mean", "median", "sum"),
    color = NULL,
    pointsAsNumbers = FALSE,
    pointSize = 0.75,
    pointAlpha = 0.8,
    label = TRUE,
    labelSize = 6L,
    dark = FALSE,
    grid = FALSE,
    legend = TRUE,
    aspectRatio = 1L,
    title = TRUE
) {
    assert_is_character(genes)
    assert_is_subset(genes, rownames(object))
    reduction <- match.arg(reduction)
    expression <- match.arg(expression)
    # Legacy support for `color = "auto"`
    if (identical(color, "auto")) {
        color <- NULL
    }
    assertIsColorScaleContinuousOrNULL(color)
    assert_is_a_bool(pointsAsNumbers)
    assert_is_a_number(pointSize)
    assert_is_a_number(pointAlpha)
    assert_is_a_bool(label)
    assert_is_a_number(labelSize)
    assert_is_a_bool(dark)
    assert_is_a_bool(legend)
    assert_is_any_of(title, c("character", "logical", "NULL"))
    if (is.character(title)) {
        assert_is_a_string(title)
    }

    # Fetch dimensional reduction coordinates
    if (reduction == "TSNE") {
        fun <- fetchTSNEExpressionData
        dimCols <- c("tSNE_1", "tSNE_2")
    } else if (reduction == "UMAP") {
        fun <- fetchUMAPExpressionData
        dimCols <- c("UMAP1", "UMAP2")
    }
    data <- fun(object, genes = genes)

    requiredCols <- c(
        "centerX",
        "centerY",
        "mean",
        "median",
        "ident",
        "sum",
        dimCols
    )
    assert_is_subset(requiredCols, colnames(data))

    p <- ggplot(
        data = data,
        mapping = aes_string(
            x = dimCols[[1L]],
            y = dimCols[[2L]],
            color = expression
        )
    )

    # Titles
    subtitle <- NULL
    if (isTRUE(title)) {
        if (is_a_string(genes)) {
            title <- genes
        } else {
            title <- NULL
            subtitle <- genes
            # Limit to the first 5 markers
            if (length(subtitle) > 5L) {
                subtitle <- c(subtitle[1L:5L], "...")
            }
            subtitle <- toString(subtitle)
        }
    } else if (identical(title, FALSE)) {
        title <- NULL
    }
    p <- p + labs(title = title, subtitle = subtitle)

    # Customize legend
    if (isTRUE(legend)) {
        if (is_a_string(genes)) {
            guideTitle <- "expression"
        } else {
            guideTitle <- expression
        }
        # Make the guide longer than normal, to improve appearance of values
        # containing a decimal point
        p <- p +
            guides(
                color = guide_colourbar(title = guideTitle)
            )
    } else {
        p <- p + guides(color = "none")
    }

    if (isTRUE(pointsAsNumbers)) {
        if (pointSize < 4L) pointSize <- 4L
        p <- p +
            geom_text(
                mapping = aes_string(
                    x = dimCols[[1L]],
                    y = dimCols[[2L]],
                    label = "ident",
                    color = expression
                ),
                alpha = pointAlpha,
                size = pointSize
            )
    } else {
        p <- p +
            geom_point(
                alpha = pointAlpha,
                size = pointSize
            )
    }

    if (isTRUE(label)) {
        if (isTRUE(dark)) {
            labelColor <- "white"
        } else {
            labelColor <- "black"
        }
        p <- p +
            geom_text(
                mapping = aes_string(
                    x = "centerX",
                    y = "centerY",
                    label = "ident"
                ),
                color = labelColor,
                size = labelSize,
                fontface = "bold"
            )
    }

    # Color palette
    if (isTRUE(dark)) {
        p <- p +
            theme_midnight(
                aspect_ratio = aspectRatio,
                grid = grid
            )
        if (is.null(color)) {
            color <- scale_colour_viridis(option = "plasma")
        }
    } else {
        p <- p +
            theme_paperwhite(
                aspect_ratio = aspectRatio,
                grid = grid
            )
        if (is.null(color)) {
            color <- scale_colour_viridis(begin = 1L, end = 0L)
        }
    }

    if (is(color, "ScaleContinuous")) {
        p <- p + color
    }

    p
}



# Methods ======================================================================
#' @rdname plotMarker
#' @export
setMethod(
    "plotMarkerTSNE",
    signature("SingleCellExperiment"),
    function(
        object,
        genes,
        expression = c("mean", "median", "sum"),
        color = NULL,
        pointsAsNumbers = FALSE,
        pointSize = 0.75,
        pointAlpha = 0.8,
        label = TRUE,
        labelSize = 6L,
        dark = FALSE,
        grid = FALSE,
        legend = TRUE,
        aspectRatio = 1L,
        title = TRUE
    ) {
        .plotMarkerReduction(
            object = object,
            genes = genes,
            reduction = "TSNE",
            expression = expression,
            color = color,
            pointsAsNumbers = pointsAsNumbers,
            pointSize = pointSize,
            pointAlpha = pointAlpha,
            label = label,
            labelSize = labelSize,
            dark = dark,
            grid = grid,
            legend = legend,
            aspectRatio = aspectRatio,
            title = title
        )
    }
)



#' @rdname plotMarker
#' @export
setMethod(
    "plotMarkerTSNE",
    signature("seurat"),
    getMethod("plotMarkerTSNE", "SingleCellExperiment")
)



#' @rdname plotMarker
#' @export
setMethod(
    "plotMarkerUMAP",
    signature("SingleCellExperiment"),
    function(
        object,
        genes,
        expression = c("mean", "median", "sum"),
        color = NULL,
        pointsAsNumbers = FALSE,
        pointSize = 0.75,
        pointAlpha = 0.8,
        label = TRUE,
        labelSize = 6L,
        dark = FALSE,
        grid = FALSE,
        legend = TRUE,
        aspectRatio = 1L,
        title = TRUE
    ) {
        .plotMarkerReduction(
            object = object,
            genes = genes,
            reduction = "UMAP",
            expression = expression,
            color = color,
            pointsAsNumbers = pointsAsNumbers,
            pointSize = pointSize,
            pointAlpha = pointAlpha,
            label = label,
            labelSize = labelSize,
            dark = dark,
            grid = grid,
            legend = legend,
            aspectRatio = aspectRatio,
            title = title
        )
    }
)



#' @rdname plotMarker
#' @export
setMethod(
    "plotMarkerUMAP",
    signature("seurat"),
    getMethod("plotMarkerUMAP", "SingleCellExperiment")
)



#' @rdname plotMarker
#' @export
setMethod(
    "plotTopMarkers",
    signature("SingleCellExperiment"),
    function(
        object,
        markers,
        reduction = c("TSNE", "UMAP"),
        headerLevel = 2L,
        ...
    ) {
        validObject(object)
        stopifnot(is(markers, "grouped_df"))
        stopifnot(.isSanitizedMarkers(markers))
        reduction <- match.arg(reduction)
        assertIsAHeaderLevel(headerLevel)

        clusters <- levels(markers[["cluster"]])
        list <- pblapply(clusters, function(cluster) {
            genes <- markers %>%
                filter(cluster == !!cluster) %>%
                pull("rowname")
            if (!length(genes)) {
                return(invisible())
            }
            if (length(genes) > 10L) {
                warning("Maximum of 10 genes per cluster is recommended")
            }

            markdownHeader(
                text = paste("Cluster", cluster),
                level = headerLevel,
                tabset = TRUE,
                asis = TRUE
            )

            lapply(genes, function(gene) {
                markdownHeader(
                    text = gene,
                    level = headerLevel + 1L,
                    asis = TRUE
                )
                p <- .plotMarkerReduction(
                    object = object,
                    genes = gene,
                    reduction = reduction,
                    ...
                )
                show(p)
                invisible(p)
            })
        })

        invisible(list)
    }
)



#' @rdname plotMarker
#' @export
setMethod(
    "plotTopMarkers",
    signature("seurat"),
    getMethod("plotTopMarkers", "SingleCellExperiment")
)



#' @rdname plotMarker
#' @export
setMethod(
    "plotKnownMarkersDetected",
    signature("SingleCellExperiment"),
    function(
        object,
        markers,
        reduction = c("TSNE", "UMAP"),
        headerLevel = 2L,
        ...
    ) {
        assert_has_rows(markers)
        stopifnot(is(markers, "grouped_df"))
        assert_has_rows(markers)
        assert_is_subset("cellType", colnames(markers))
        reduction <- match.arg(reduction)
        assertIsAHeaderLevel(headerLevel)

        cellTypes <- markers %>%
            pull("cellType") %>%
            na.omit() %>%
            unique()
        assert_is_non_empty(cellTypes)

        list <- pblapply(cellTypes, function(cellType) {
            genes <- markers %>%
                filter(cellType == !!cellType) %>%
                pull("geneName") %>%
                na.omit() %>%
                unique()
            assert_is_non_empty(genes)

            markdownHeader(
                text = cellType,
                level = headerLevel,
                tabset = TRUE,
                asis = TRUE
            )

            lapply(genes, function(gene) {
                markdownHeader(
                    text = gene,
                    level = headerLevel + 1L,
                    asis = TRUE
                )
                p <- .plotMarkerReduction(
                    object = object,
                    genes = gene,
                    reduction = reduction,
                    ...
                )
                show(p)
                invisible(p)
            })
        })

        invisible(list)
    }
)



#' @rdname plotMarker
#' @export
setMethod(
    "plotKnownMarkersDetected",
    signature("seurat"),
    getMethod("plotKnownMarkersDetected", "SingleCellExperiment")
)
