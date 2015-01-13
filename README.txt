Mid Coast TMDL Data Layers for Google Earth Display
Peter Bryant, Oregon Department of Environmental Quality
January 14th, 2015

There are five layers in this .zip folder.

MidCoast.kmz - Outline of the Mid Coast administrative basin delineation.

NHDPv21_Flowline.kmz - The National Hydrography Dataset Plus version 2.1 stream lines from the NHDPlus dataset.

Sedimentation303d.kmz - 303(d) listed streams for sedimentation in the Mid Coast. This layer are only streams listed for sedimentation and only in the Mid Coast. From the OR Assessment Geodatabase.

SedimentStressorStations.kml - Mid Coast stations with biocriteria impairment with sediment identified as a stressor.

SourceAnalysisDevelopmentStations.kml - Stations used in the Source Analysis model development process.

Fields in both Station Specific Layers:
STATION_KEY - Station identifier
SITE_NAME - Station location description
SAMPLE_DATE - Date macroinvertebrate sample was collected
Biocriteria Impaired - One of 4 values: "Yes" - Only for samples in the Mid Coast macroinvertebrate sample showed impairment
				   	"No"  - Only for samples in the Mid Coast macroinvertebrate sample did no show impairment
					"Not assessed" - For new samples added to bolster data used for source analysis. Biocriteria status not yet determined.
				        "Outside Mid Coast" - Samples were used in source analysis model development but are not a part of the Mid Coast TMDL.
FSS - Fine sediment score from data collected on SAMPLE_DATE
Sediment Stressor Identified - One of 2 valuesL "Yes" - FSS indicates sediment stressor present
						"No" - FSS inidcates sediment is not a stressor
TMDL_Target - For those stations in the Mid Coast where Biocriteria impairment has been identified and sediment has been identified as the primary stressor the target FSS value for the TMDL. Note: For the Source Analysis Development Stations these will all be NA.
sum_1095_days - Sum of rainfall over a 1095 day period prior to the sample date
PALITHERODRCA - Percent of Accumulated Reach Contributing Area with erodible classified lithology
STRMPWR - Stream power calculated as slope (XSLOPE_MAP) multiplied by flow (Q0001A)
MIN_Z - Minimum elevation in the sample reach
PASILTRCA - Percent of weighted average percent silt (0.002 to 0.05mm) between 6 – 36 inches within the Accumulated Reach Contributing Area
PACLAYRCA - Percent of weighted average percent clay (<0.002mm) between 6 – 36 inches within the Accumulated Reach Contributing Area
XSLOPE_MAP - Percent slope of the sampling reach
PASUSCEP5_DE - Percent of Accumulated Reach Contributing Area with high landslide susceptibility based on 30 meter DEM
DAPOPRCA2010 - Estimated human population density in the Accumulated Reach Contributing Area in the year 2010
LAT_RAW - Latitude of sample location
POWNRCA_PRI - Percent of reach contributing area with private forest land
PDISRSA_1YR - Percent land disturbance in the last year since the sample date within the Reach Streamside Area
DAROADX - Density of stream/road crossings in the accumulated Reach Contributing Area
PAOWNRCA_AGR - Percent of accumulated reach contributing area with agricultural land
