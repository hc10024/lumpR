% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/area2catena.R
\name{area2catena}
\alias{area2catena}
\title{Calculates mean catena from spatial data}
\usage{
area2catena(mask = NULL, flowacc = NULL, eha = NULL, distriv = NULL,
  elevriv = NULL, supp_quant = NULL, supp_qual = NULL, dir_out = "./",
  catena_out = NULL, catena_head_out = NULL, ridge_thresh = 1,
  min_cell_in_slope = 30, min_catena_length = 3, max_riv_dist = 10,
  plot_catena = F, grass_files = F, ncores = 1, eha_subset = NULL,
  overwrite = F, silent = F)
}
\arguments{
\item{mask}{Raster file to be used as MASK in the GRASS location defining the
area of interest. E.g. \code{mask_corr} of \code{\link[lumpR]{lump_grass_prep}}.}

\item{flowacc}{Name of flow accumulation raster map in GRASS location. Can
be created with \code{\link[lumpR]{lump_grass_prep}}.}

\item{eha}{Name of elementary hillslope area raster map in GRASS location.
Can be created with \code{\link[lumpR]{lump_grass_prep}}.}

\item{distriv}{Name of distance to river raster map in GRASS location. Can
be created with \code{\link[lumpR]{lump_grass_prep}}.}

\item{elevriv}{Name of relative elevation raster map in GRASS location. Can
be created with \code{\link[lumpR]{lump_grass_prep}}.}

\item{supp_quant}{Character vector containing names of quantitative
supplemental raster maps in GRASS location; leave empty if you have none.}

\item{supp_qual}{Character vector containing names of qualitative
supplemental raster maps in GRASS location; leave empty if you have none.}

\item{dir_out}{Character string specifying output directory (will be created;
nothing will be overwritten).}

\item{catena_out}{Output: Name of output file containing mean catena information
as input for \code{\link[lumpR]{prof_class}}.}

\item{catena_head_out}{Output: Name of output header file containing meta-information
as input for \code{\link[lumpR]{prof_class}}; manual adjustment necessary.}

\item{ridge_thresh}{Integer specifying threshold of flow accumulation, below
which a cell is considered a start of a flowpath (usually 1 for D8
flowaccumulation grids).}

\item{min_cell_in_slope}{Integer specifying minimum number of cells a hillslope
area must have, all smaller ones are skipped.}

\item{min_catena_length}{Integer specifying minimum number of sampling points
(cells) a catena should have. If there are less, the catena is not saved.}

\item{max_riv_dist}{Integer specifying maximum distance to river [in cells]:
if the closest cell of an EHA is farther than \code{max_riv_dist}, the EHA
is skipped, otherwise all distances within the EHA are redurced by the
distance of the closest cell to river.}

\item{plot_catena}{logical; produce plots (scatter, mean catena, etc.) for
each area / class (written into sub-directory \emph{plots_area2catena}).}

\item{grass_files}{logical; produce GRASS reclassification files for qualitative
raster data.}

\item{ncores}{Ineger specifying number of cores that should be used for computation.}

\item{eha_subset}{NULL or integer vector with subset of EHA ids that shall
be processed (for debugging and testing).}

\item{overwrite}{\code{logical}. Shall output of previous calls of this function be
deleted? If \code{FALSE} the function returns an error if output already exists.
Default: \code{FALSE}.}

\item{silent}{\code{logical}. Shall the function be silent (also suppressing summary
after function execution)? Default: \code{FALSE}.}
}
\value{
Function returns nothing. Output files are written into output directory
     as specified in arguments.
}
\description{
Takes raster data from a GRASS location and calculates catena properties.
}
\note{
Prepare GRASS location and necessary raster files in advance (e.g. using
     \code{\link[lumpR]{lump_grass_prep}}) and start GRASS session in R using 
     \code{\link[spgrass6]{initGRASS}}.
     
     GUIs such as RStudio may not produce some runtime messages (within parallel
     foreach loop).
     
     File \code{catena_out} contains information about the representative catena
     for each hillslope (EHA). For meaning of columns see file \code{catena_head_out}.
     It usually contains the catena ID, the catena's profile point IDs, relative
     vertical elevation above hillside toe, and supplemental information averaged
     over all raster cells associated with a specific catena profile point. For
     qualitative data the latter means the areal fraction of a specific attribute
     class (sum over all classes of an attribute should be equal to one for a profile
     point), for quantitative data it is a numerical value. Averages over raster
     cells are weighted by relative flow path densities of the raster cells. For
     more details on the algorithm see the reference below.
}
\references{
Source code based on \code{SHELL} and \code{MATLAB} scripts of Till Francke.

     Theory of LUMP:\cr
     Francke, T.; Guentner, A.; Mamede, G.; Mueller, E. N. and Bronstert, A (2008):
     Automated catena-based discretization of landscapes for the derivation of
     hydrological modelling units. \emph{International Journal of Geographical
     Information Science, Informa UK Limited}, 22(2), 111-132, DOI: 10.1080/13658810701300873
}
\author{
Tobias Pilz \email{tpilz@uni-potsdam.de}, Till Francke \email{francke@uni-potsdam.de}
}
