# lumpR/db_fill.R
# Copyright (C) 2015, 2017 Tobias Pilz
# 
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
# 
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
# 
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.


#' Fill parameter database
#' 
#' Function to write parameter values relevant for modelling application with the
#' WASA hydrological model into an existing database, preferably created with
#' \code{\link[lumpR]{db_create}}.
#' 
#' @param dbname Name of the data source (DSN) registered at ODBC. See \code{Details} of
#' \code{\link[lumpR]{db_create}}.
#' 
#' @param tables \code{vector} with name(s) of the table(s) in the database that should
#'  be filled with data. Order must correspond to the order of \code{dat_files}. By
#'  default all tables are specified (see \code{Usage} for order of \code{dat_files}).
#'  See \code{Details} for more information.
#'  
#' @param dat_files \code{vector} with name(s) of the file(s) containing the data
#'  that should be written into the database. Order must correspond to the order of
#'  \code{tables}. See \code{Details} for information on file strcuture.
#'  
#' @param dat_dir \code{string} giving the path to the directory containing \code{dat_files}.
#'  
#' @param overwrite \code{logical}. Should Existing data be overwritten? If \code{FALSE}
#'  existing values will be kept und the table expanded. Default: \code{FALSE}.
#' 
#' @param verbose \code{logical}. Should detailed information during execution be
#'  printed? Default: \code{TRUE}.
#'  
#' @details 
#'  For each table a single file has to be prepared manually and/or using functions of
#'  \code{lumpR}. All files have to be tabulator-separated textfiles, the top-line
#'  being the header. Column names have to be identical to column names of the 
#'  respective tables in the database. All columns of a table have to exist in the 
#'  respective data file. If a certain column is not needed for your purpose or
#'  contains missing values set values to \code{NA}. However, additional columns may exist
#'  and will be omitted during database import and the order of the columns may be
#'  freely chosen. Commentary lines are allowed and will be omitted during data import;
#'  these have to begin with \code{#}. Duplicate entries or entries in the input file
#'  which are already in the database table (unless you set \code{overwrite=T}) 
#'  are not allowed and produce an error.
#'  
#'  \bold{r_subbas_contains_lu}\cr
#'  Table referncing subbasins and corresponding landscape units inclunding their
#'  areal fraction. \code{lu_ofile} produced by \code{\link[lumpR]{lump_grass_post}} 
#'  can be used. Columns:
#'  
#'    \emph{subbas_id}\cr
#'    \code{integer}. Subbasin ID.
#'  
#'    \emph{lu_id}\cr
#'    \code{integer}. Landscape Unit ID.
#'  
#'    \emph{fraction}\cr
#'    \code{double}. Areal fraction of landscape unit within subbasin \emph{[-]}.
#'  
#'  
#'  \bold{subbasins}\cr
#'  Subbasin parameters. \code{sub_ofile} produced by \code{\link[lumpR]{lump_grass_post}} 
#'  can be used. Columns:
#'  
#'    \emph{pid}\cr
#'    \code{integer}. Subbasin identifier.
#'  
#'    \emph{description}\cr
#'    \code{character}. Short subbasin name or description.
#'  
#'    \emph{drains_to}\cr
#'    \code{integer}. Pid of subbasin the current subbasin drains to. The outlet
#'    subbasin has to be labelled by one of c(9999,-9999,999,-999).
#'  
#'    \emph{area}\cr
#'    \code{double}. Subbasin area in \emph{km^2}.
#'  
#'    \emph{a_stream_order}\cr
#'    \code{integer}. Stream order. Set to \code{NA}. Calculated during WASA
#'    input file creation.
#'      
#'    \emph{lag_time}\cr
#'    \code{double}. Time in \emph{days} a runoff signal in the current
#'      subbasin needs to be directed from the subbasin input to the outlet.
#'      
#'    \emph{retention}\cr
#'    \code{double}. Maximum time period in \emph{days} over which a runoff signal
#'    is distributed by the routing process.
#'    
#'    
#'  \bold{landscape_units}\cr
#'  Landscape Unit parameters. Information can be obtained from \code{luoutfile}
#'  created by \code{\link[lumpR]{prof_class}} (column 'x_length' which is identical
#'  to 'slopelength') and \code{lupar_ofile} created by \code{\link[lumpR]{lump_grass_post}}
#'  (all other information). Merge information by hand. Columns:
#'  
#'    \emph{pid}\cr
#'    \code{integer}. Landscape Unit ID.
#'    
#'    \emph{description}\cr
#'    \code{character}. Short name or description.
#'    
#'    \emph{kf_bedrock}\cr
#'    \code{double}. Hydraulic conductivity of bedrock in \emph{mm/d}.
#'    
#'    \emph{slopelength}\cr
#'    \code{double}. Mean slope length in landscape unit in \emph{m}. Meant is
#'    the length in x-direction, not the hypotenuse of the hillslope profile triangle.
#'    
#'    \emph{soil_depth}\cr
#'    \code{double}. Mean maximum depth of soil zone in \emph{mm}.
#'    
#'    \emph{allu_depth}\cr
#'    \code{double}. Mean maximum depth of alluvial soil zone in \emph{mm}.
#'    
#'    \emph{riverbed_depth}\cr
#'    \code{double}. Depth of river bed below terrain component in \emph{mm}.
#'    
#'    \emph{gw_flag}\cr
#'    \code{integer}. Groundwater flag; 0: no groundwater, 1: with groundwater.
#'    
#'    \emph{gw_dist}\cr
#'    \code{double}. Initial depth of groundwater below surface in \emph{mm}.
#'    
#'    \emph{frgw_delay}\cr
#'    \code{double}. Storage coefficient for groundwater outflow in \emph{days}.
#'    
#'    \emph{sdr_lu}\cr
#'    \code{double}. Sediment delivery ratio on LU-scale. For erosion modelling, only.
#'    
#'    
#'  \bold{r_lu_contains_tc}\cr
#'  Table referncing landscape units and corresponding terrain components inclunding their
#'  areal fraction and hillslope position. \code{lucontainstcoutfile} created by
#'  \code{\link[lumpR]{prof_class}} can be used directly. Columns:
#'  
#'    \emph{lu_id}\cr
#'    \code{integer}. Landscape unit ID.
#'    
#'    \emph{tc_id}\cr
#'    \code{integer}. Terrain component ID.
#'    
#'    \emph{fraction}\cr
#'    \code{double}. Areal fraction of TC within LU \emph{[-]}.
#'    
#'    \emph{position}\cr
#'    \code{integer}. Hillslope position of TC in LU (counting from hillslope bottom).
#'    
#'    
#'  \bold{terrain_components}\cr
#'  Terrain component specific parameters. Information from \code{terraincomponentsoutfile}
#'  created by \code{\link[lumpR]{prof_class}} can be used. Columns:
#'  
#'    \emph{pid}\cr
#'    \code{integer}. Terrain component ID.
#'    
#'    \emph{description}\cr
#'    \code{character}. Short name or description.
#'    
#'    \emph{slope}\cr
#'    \code{double}. Slope of terrain component in \emph{\%}.
#'    
#'    \emph{frac_rocky}\cr
#'    \code{double}. Fraction of impermeable (rock) area \emph{[-]}.
#'    
#'    \emph{beta_fac}\cr
#'    \code{double}. Ratio of rill/interrill erosion (for computation of the 
#'    L-factor see Renard et al., 1997, pp.101). For erosion modelling, only.
#'    
#'    \emph{sdr}\cr
#'    \code{double}. Sediment delivery ratio on TC-scale. For erosion modelling, only.
#'    
#'    
#'  \bold{r_tc_contains_svc}\cr
#'  Table referncing terrain components and corresponding soil-vegetation components
#'  inclunding their areal fraction. \code{tccontainssvcoutfile} created by
#'  \code{\link[lumpR]{prof_class}} can be used directly. Columns:
#'    
#'    \emph{tc_id}\cr
#'    \code{integer}. Terrain component ID.
#'    
#'    \emph{svc_id}\cr
#'    \code{integer}. Soil-vegetation component ID.
#'    
#'    \emph{fraction}\cr
#'    \code{double}. Areal fraction of SVC within TC \emph{[-]}.
#'    
#'    
#'  \bold{vegetation}\cr
#'  Vegetation parameters. Columns:
#'  
#'    \emph{pid}\cr
#'    \code{integer}. Vegetation type ID.
#'    
#'    \emph{description}\cr
#'    \code{character}. Short name or description.
#'    
#'    \emph{stomat_r}\cr
#'    \code{double}. Stomata resistance without water stress in \emph{s/m}.
#'    
#'    \emph{min_suction}\cr
#'    \code{double}. Suction threshold for water stress effect on resistance:
#'    Begin of stomata closure. In \emph{hPa}.
#'    
#'    \emph{max_suction}\cr
#'    \code{double}. Suction threshold for water stress effect on resistance:
#'    Total closure of stomata, wilting point. In \emph{hPa}.
#'    
#'    \emph{height1}\cr
#'    \code{double}. Average height of vegetation canopy \emph{before} rainy season in \emph{m}.
#'    
#'    \emph{height2}\cr
#'    \code{double}. Average height of vegetation canopy \emph{at the beginning of} rainy season in \emph{m}.
#'    
#'    \emph{height3}\cr
#'    \code{double}. Average height of vegetation canopy \emph{at the end of} rainy season in \emph{m}.
#'    
#'    \emph{height4}\cr
#'    \code{double}. Average height of vegetation canopy \emph{after} rainy season in \emph{m}.
#'    
#'    \emph{root_depth1}\cr
#'    \code{double}. Rooting depth of vegetation \emph{before} rainy season in \emph{m}.
#'    
#'    \emph{root_depth2}\cr
#'    \code{double}. Rooting depth of vegetation \emph{at the beginning of} rainy season in \emph{m}.
#'    
#'    \emph{root_depth3}\cr
#'    \code{double}. Rooting depth of vegetation \emph{at the end of} rainy season in \emph{m}.
#'    
#'    \emph{root_depth4}\cr
#'    \code{double}. Rooting depth of vegetation \emph{after} rainy season in \emph{m}.
#'    
#'    \emph{lai1}\cr
#'    \code{double}. Leaf area index of vegetation cover \emph{before} rainy season \emph{[-]}.
#'    
#'    \emph{lai2}\cr
#'    \code{double}. Leaf area index of vegetation cover \emph{at the beginning of} rainy season \emph{[-]}.
#'    
#'    \emph{lai3}\cr
#'    \code{double}. Leaf area index of vegetation cover \emph{at the end of} rainy season \emph{[-]}.
#'    
#'    \emph{lai4}\cr
#'    \code{double}. Leaf area index of vegetation cover \emph{after} rainy season \emph{[-]}.
#'    
#'    \emph{alb1}\cr
#'    \code{double}. Surface albedo \emph{before} rainy season \emph{[-]}.
#'  
#'    \emph{alb2}\cr
#'    \code{double}. Surface albedo \emph{at the beginning of} rainy season \emph{[-]}.
#'    
#'    \emph{alb3}\cr
#'    \code{double}. Surface albedo \emph{at the end of} rainy season \emph{[-]}.
#'    
#'    \emph{alb4}\cr
#'    \code{double}. Surface albedo \emph{after} rainy season \emph{[-]}.
#'    
#'    \emph{c_manning_n}\cr
#'    \code{double}. \emph{Optional for Erosion modelling}.
#'
#'    \emph{c_musle_c1}\cr
#'    \code{double}. \emph{Optional for Erosion modelling}.
#'    
#'    \emph{c_musle_c2}\cr
#'    \code{double}. \emph{Optional for Erosion modelling}.  
#'    
#'    \emph{c_musle_c3}\cr
#'    \code{double}. \emph{Optional for Erosion modelling}.  
#'    
#'    \emph{c_musle_c4}\cr
#'    \code{double}. \emph{Optional for Erosion modelling}.
#'    
#'    
#'  \bold{soils}\cr
#'  General soil parameters (horizon-specific parameters see below). Columns:
#'  
#'    \emph{pid}\cr
#'    \code{integer}. Soil type ID.
#'    
#'    \emph{description}\cr
#'    \code{character}. Short name or description.
#'    
#'    \emph{bedrock_flag}\cr
#'    \code{integer}. Bedrock below deepest horizon: 0: not considered, 1: considered.
#'    
#'    \emph{alluvial_flag}\cr
#'    \code{integer}. Soil type is alluvial soil: 0: no, 1: yes.
#'    
#'    \emph{b_om}\cr
#'    \code{double}. Topsoil organic matter content (mass fraction) \emph{[-]}.
#'    
#'    \emph{a_musle_k}\cr
#'    \code{double}. Used for internal calculations, set \code{NA}.
#'    
#'    \emph{a_clay}\cr
#'    \code{double}. Used for internal calculations, set \code{NA}.
#'    
#'    \emph{a_silt}\cr
#'    \code{double}. Used for internal calculations, set \code{NA}.
#'    
#'    \emph{a_sand}\cr
#'    \code{double}. Used for internal calculations, set \code{NA}.
#'    
#'    \emph{a_f_csand}\cr
#'    \code{double}. Used for internal calculations, set \code{NA}.
#'    
#'    \emph{a_f_cl_si}\cr
#'    \code{double}. Used for internal calculations, set \code{NA}.
#'    
#'    \emph{a_f_orgc}\cr
#'    \code{double}. Used for internal calculations, set \code{NA}.
#'    
#'    \emph{a_f_hisand}\cr
#'    \code{double}. Used for internal calculations, set \code{NA}.
#'    
#'    
#'  \bold{horizons}\cr
#'  Horizon specific soil parameters. Columns:
#'  
#'    \emph{pid}\cr
#'    \code{integer}. Horizon ID.
#'    
#'    \emph{description}\cr
#'    \code{character}. Short name or description.
#'    
#'    \emph{soil_id}\cr
#'    \code{integer}. Soil type ID.
#'    
#'    \emph{position}\cr
#'    \code{integer}. Position of soil type specific horizon counting from surface.
#'    
#'    \emph{theta_r}\cr
#'    \code{double}. Residual volumetric soil water content \emph{[-]}.
#'    
#'    \emph{theta_pwp}\cr
#'    \code{double}. Volumetric soil water content at permanent wilting point \emph{[-]}.
#'    
#'    \emph{fk}\cr
#'    \code{double}. Volumetric soil water content at field capacity (316 hPa / pF=2.6) \emph{[-]}.
#'    
#'    \emph{fk63}\cr
#'    \code{double}. Volumetric soil water content at field capacity (63 hPa / pF=1.8) \emph{[-]}.
#'    
#'    \emph{nfk}\cr
#'    \code{double}. Usable field capacity in terms of volumetric soil water content \emph{[-]}.
#'    
#'    \emph{theta_s}\cr
#'    \code{double}. Saturated volumetric soil water content \emph{[-]}.
#'    
#'    \emph{thickness}\cr
#'    \code{double}. Thickness of soil horizon in \emph{mm}.
#'    
#'    \emph{ks}\cr
#'    \code{double}. Saturated hydraulic conductivity in \emph{mm/day}.
#'    
#'    \emph{suction}\cr
#'    \code{double}. Suction at the wetting front in \emph{mm}.
#'    
#'    \emph{pore_size_i}\cr
#'    \code{double}. Pore size index.
#'    
#'    \emph{bubb_pres}\cr
#'    \code{double}. Bubble pressure in \emph{cm}.
#'    
#'    \emph{coarse_frag}\cr
#'    \code{double}. Volumetric fraction of coarse fragments \emph{[-]}.
#'    
#'    \emph{shrinks}\cr
#'    \code{integer}. Flag for soil structure, currently not used, set to \code{0} (not \code{NA}!).
#'    
#'    
#'  \bold{soil_veg_components}\cr
#'  Parameters specific for soil-vegetation components. \code{svc_ofile} created by
#'  \code{\link[lumpR]{lump_grass_prep}} can be used directly. Columns:
#'  
#'    \emph{pid}\cr
#'    \code{integer}. Soil-vegetation component ID.
#'    
#'    \emph{description}\cr
#'    \code{character}. Short name or description.
#'    
#'    \emph{soil_id}\cr
#'    \code{integer}. Soil type ID.
#'    
#'    \emph{veg_id}\cr
#'    \code{integer}. Vegetation type ID.
#'    
#'    \emph{musle_k}\cr
#'    \code{double}. MUSLE K-factor [(ton acre hr)/(acre ft-ton inch)].
#'    
#'    \emph{musle_p}\cr
#'    \code{double}. MUSLE P-factor.
#'    
#'    \emph{coarse_frac}\cr
#'    \code{double}. Fraction of coarse fragments in \emph{\%}.
#'    
#'    \emph{special_area}\cr
#'    \code{integer}. Flag for special areas: 1: water, 2: impervious, 0: ordinary SVC.
#'    
#'    \emph{manning_n}\cr
#'    \code{double}. Mannings n roughness coefficient for overland flow.
#'    
#'    \emph{musle_c1}\cr
#'    \code{double}. \emph{Optional for Erosion modelling}.
#'    
#'    \emph{musle_c2}\cr
#'    \code{double}. \emph{Optional for Erosion modelling}.  
#'    
#'    \emph{musle_c3}\cr
#'    \code{double}. \emph{Optional for Erosion modelling}.  
#'    
#'    \emph{musle_c4}\cr
#'    \code{double}. \emph{Optional for Erosion modelling}.
#'    
#'    
#'  \bold{particle_classes}\cr
#'  Definition of particle size classes. Columns:
#'  
#'    \emph{class_id}\cr
#'    \code{integer}. Particle class ID.
#'    
#'    \emph{description}\cr
#'    \code{character}. Short name or description.
#'    
#'    \emph{upper_limit}\cr
#'    \code{double}. Upper size limit of particles in \emph{mm}.
#'    
#'    
#'  \bold{r_soil_contains_particles}\cr
#'  Table referncing soil types and corresponding particle size classes including
#'  their specific shares. Columns:
#'  
#'    \emph{soil_id}\cr
#'    \code{integer}. Soil type ID.
#'    
#'    \emph{class_id}\cr
#'    \code{integer}. Particle class ID.
#'    
#'    \emph{fraction}\cr
#'    \code{double}. Mass-fraction that falls into the respective particle size class \emph{[-]}.
#'    
#'    
#'  \bold{rainy_season}\cr
#'  Fill in output of \code{\link[lumpR]{rainy_season}}. You can define separate
#'  seasonalities for different vegetation types if you want (i.e. 'growing season'
#'  instead of 'rainy season'). In this case the rainy/growing season starts and ends
#'  differently for the respective vegetation types. This, however, is not
#'  respected by function \code{\link[lumpR]{rainy_season}} which determines seasonalities
#'  based on precipitation only. You can use the wildcard value '-1' for all
#'  (remaining) vegetation types.
#'  Columns:
#'    
#'    \emph{pid}\cr
#'    \code{integer}. Dataset ID.
#'    
#'    \emph{subbas_id}\cr
#'    \code{integer}. Id of subbasin or '-1' as wildcard for all (remaining) subbasins.
#'    
#'    \emph{veg_id}\cr
#'    \code{integer}. Id of vegetation type or '-1' as wildcard for all (remaining)
#'    vegetation types.
#'    
#'    \emph{yearm}\cr
#'    \code{integer}. Current year or '-1' as wildcard for all (remaining) years.
#'    
#'    \emph{node1}\cr
#'    \code{integer}. Start day of year (DOY) of rainy/growing season.
#'    
#'    \emph{node2}\cr
#'    \code{integer}. DOY when climax of vegetation is reached.
#'    
#'    \emph{node3}\cr
#'    \code{integer}. DOY of end of rainy/growing season (begin of vegetation degradation).
#'    
#'    \emph{node4}\cr
#'    \code{integer}. DOY of end of main phase of vegetation degradation.
#'  
#'          
#' 
#' @references
#'      \bold{Theory of lumpR}\cr
#'      Francke, T.; Guentner, A.; Mamede, G.; Mueller, E. N. and Bronstert, A (2008):
#'      Automated catena-based discretization of landscapes for the derivation of
#'      hydrological modelling units. \emph{International Journal of Geographical
#'      Information Science, Informa UK Limited}, 22(2), 111-132, DOI: 10.1080/13658810701300873
#'      
#'      \bold{Information on WASA and parameters}\cr
#'      Guentner, A. (2002): Large-scale hydrological modelling in the semi-arid 
#'      North-East of Brazil. \emph{PIK Report 77}, Potsdam Institute for Climate
#'      Impact Research, Potsdam, Germany.
#'      
#'      \bold{More information on subbasin parameters}\cr
#'      Bronstert, A., Guentner, A., Jaeger, A., Krol, M. & Krywkow, J. (1999): Grossraeumige
#'      hydrologische Parametrisierung und Modellierung als Teil der integrierten 
#'      Modellierung. In: Fohrer, N. & Doell, P. (Eds.): Modellierung des Wasser- und
#'      Stofftransports in grossen Einzugsgebieten. \emph{Kassel University Press}, Kassel,
#'      Germany, 31-40.
#'      
#' 
#' @author 
#'  Tobias Pilz \email{tpilz@@uni-potsdam.de}, Till Francke \email{francke@@uni-potsdam.de}
#' 
db_fill <- function(
  dbname,
  tables=c("r_subbas_contains_lu", "subbasins", "landscape_units", "r_lu_contains_tc",
           "terrain_components", "r_tc_contains_svc", "vegetation", "soils", "horizons",
           "soil_veg_components", "particle_classes", "r_soil_contains_particles", "rainy_season"),
  dat_files,
  dat_dir,
  overwrite=FALSE,
  verbose=TRUE
) {
  
  
  if (verbose)
    print("Loading package 'RODBC' and connecting to database ...")
  
  # connect to ODBC registered database
  suppressWarnings(con <- odbcConnect(dbname, believeNRows=F))
  
  if (con == -1)
    print(paste0("Could not connect to database '", dbname, "'. Type 'odbcDataSources()' to see the data sources known to ODBC.",
                 " If you want to connect to a MS Access database make sure you are using 32 bit R."))
  
  # check database (all 'tables' have to exist)
  check_tbl <- tables %in% sqlTables(con)$TABLE_NAME
  if (any(!check_tbl)) {
    odbcClose(con)
    stop(paste0("Table(s) ", paste(tables[which(!check_tbl)], sep=", "), " could not be found in database '", dbname, "'."))
  }
 
  
  # write data into database (use internal function defined in db_internals.R)
  for (t in 1:length(tables)) {
    writedb(con = con, file = paste(dat_dir,dat_files[t], sep="/"), table = tables[t],
            overwrite = overwrite, verbose = verbose)
  }
  
  # update table meta_info
  meta_dat <- sqlFetch(con, "meta_info")
  if(any(meta_dat$pid)) {
    pid_new <- max(meta_dat$pid) +1
  } else {
    pid_new <- 1
  }
  meta_out <- data.frame(pid=pid_new,
                         mod_date=as.POSIXct(Sys.time()),
                         mod_user=paste0("db_fill(), v. ", installed.packages()["lumpR","Version"]),
                         affected_tables=paste(tables, collapse=", "),
                         affected_columns="all",
                         remarks=paste0("Automated filling of tables with R package lumpR using files from location ", dat_dir, "."))
  write_datetabs(con, meta_out, tab="meta_info", verbose)
  
  
  # close connection
  odbcClose(con)
  
  
} # EOF

