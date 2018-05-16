#' Plot Cell-Type Gene Marker(s)
#'
#' @description
#' Plot gene expression per cell in multiple formats:
#'
#' 1. t-SNE plot
#' 2. Violin plot
#' 3. Ridgeline plot
#' 4. Dot plot
#'
#' @name plotMarker
#' @family Clustering Functions
#' @author Michael Steinbaugh
#'
#' @inheritParams general
#' @param gene Gene identifier. Must intersect with [rownames()].
#'
#' @return Show graphical output. Invisibly return `ggplot` `list`.
#'
#' @seealso
#' - [plotMarkerTSNE()].
#' - [plotDot()].
#' - [plotViolin()].
#'
#' @examples
#' # seurat ===
#' # Individual gene
#' plotMarker(seurat_small, gene = "COL1A2", dark = TRUE)
#' plotMarker(seurat_small, gene = "COL1A2", dark = FALSE)
#'
#' # Multiple genes
#' top <- topMarkers(all_markers_small, n = 1L)
#' genes <- pull(top, "rowname")
#' plotMarkers(seurat_small, genes = genes)
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



# Methods ======================================================================
#' @rdname plotMarker
#' @export
setMethod(
    "plotMarker",
    signature("seurat"),
    function(
        object,
        gene,
        dark = TRUE,
        return = c("grid", "list"),
        ...
    ) {
        assert_is_a_string(gene)
        assert_is_a_bool(dark)
        return <- match.arg(return)

        # Plots ================================================================
        if (isTRUE(dark)) {
            violinFill <- "white"
        } else {
            violinFill <- "black"
        }

        tsne <- plotMarkerTSNE(
            object,
            genes = gene,
            expression = "sum",
            dark = dark,
            ...
        )

        dot <- plotDot(
            object,
            genes = gene,
            dark = dark
        )

        violin <- plotViolin(
            object,
            genes = gene,
            scale = "width",
            fill = violinFill,
            dark = dark,
            return = "list"
        )
        # Get the ggplot object from the list return
        violin <- violin[[1L]]

        # Return ===============================================================
        if (return == "grid") {
            violin <- violin +
                .minimalAxis()
            dot <- dot +
                coord_flip() +
                .minimalAxis()
            p <- plot_grid(
                tsne,
                dot,
                violin,
                labels = NULL,
                ncol = 1L,
                nrow = 3L,
                rel_heights = c(1L, 0.1, 0.15)
            )
            if (isTRUE(dark)) {
                p <- p + theme(
                    plot.background = element_rect(color = NA, fill = "black")
                )
            } else {
                p <- p + theme(
                    plot.background = element_rect(color = NA, fill = "white")
                )
            }
            p
        } else if (return == "list") {
            list(
                "tsne" = tsne,
                "dot" = dot,
                "violin" = violin
            )
        }
    }
)



#' @rdname plotMarker
#' @export
setMethod(
    "plotMarkers",
    signature("seurat"),
    function(
        object,
        genes,
        headerLevel = 2L,
        ...
    ) {
        assert_is_character(genes)
        assert_is_subset(genes, rownames(object))
        assertIsAHeaderLevel(headerLevel)

        list <- lapply(genes, function(gene) {
            markdownHeader(gene, level = headerLevel, asis = TRUE)
            p <- plotMarker(
                object = object,
                gene = gene,
                ...
            )
            show(p)
            invisible(p)
        })

        invisible(list)
    }
)