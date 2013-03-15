/****** Object:  Table [T_Instrument_Class] ******/
/****** RowCount: 24 ******/
/****** Columns: IN_class, is_purgable, raw_data_type, requires_preparation, x_Allowed_Dataset_Types, Params, Comment ******/
INSERT INTO [T_Instrument_Class] VALUES ('Agilent_Ion_Trap',0,'dot_d_folders',0,'No longer used: MS, MS-MSn','<sections><section name="DatasetQC"><item key="SaveTICAndBPIPlots" value="True" /><item key="SaveLCMS2DPlots" value="True" /><item key="ComputeOverallQualityScores" value="True" /><item key="CreateDatasetInfoFile" value="True" /><item key="LCMS2DPlotMZResolution" value="0.4" /><item key="LCMS2DPlotMaxPointsToPlot" value="500000" /><item key="LCMS2DPlotMinPointsPerSpectrum" value="2" /><item key="LCMS2DPlotMinIntensity" value="0" /><item key="LCMS2DOverviewPlotDivisor" value="10" /></section></sections>','')
INSERT INTO [T_Instrument_Class] VALUES ('Agilent_TOF',0,'dot_wiff_files',0,'No longer used: HMS','<sections><section name="DatasetQC"><item key="SaveTICAndBPIPlots" value="True" /><item key="SaveLCMS2DPlots" value="True" /><item key="ComputeOverallQualityScores" value="True" /><item key="CreateDatasetInfoFile" value="True" /><item key="LCMS2DPlotMZResolution" value="0.4" /><item key="LCMS2DPlotMaxPointsToPlot" value="500000" /><item key="LCMS2DPlotMinPointsPerSpectrum" value="2" /><item key="LCMS2DPlotMinIntensity" value="0" /><item key="LCMS2DOverviewPlotDivisor" value="10" /></section></sections>','')
INSERT INTO [T_Instrument_Class] VALUES ('Agilent_TOF_V2',1,'dot_d_folders',0,'','<sections><section name="DatasetQC"><item key="SaveTICAndBPIPlots" value="True" /><item key="SaveLCMS2DPlots" value="True" /><item key="ComputeOverallQualityScores" value="True" /><item key="CreateDatasetInfoFile" value="True" /><item key="LCMS2DPlotMZResolution" value="0.4" /><item key="LCMS2DPlotMaxPointsToPlot" value="500000" /><item key="LCMS2DPlotMinPointsPerSpectrum" value="2" /><item key="LCMS2DPlotMinIntensity" value="0" /><item key="LCMS2DOverviewPlotDivisor" value="10" /></section></sections>','')
INSERT INTO [T_Instrument_Class] VALUES ('Bruker_Amazon_Ion_Trap',1,'bruker_ft',0,'','<sections><section name="DatasetQC"><item key="SaveTICAndBPIPlots" value="True" /><item key="SaveLCMS2DPlots" value="True" /><item key="ComputeOverallQualityScores" value="True" /><item key="CreateDatasetInfoFile" value="True" /><item key="LCMS2DPlotMZResolution" value="0.4" /><item key="LCMS2DPlotMaxPointsToPlot" value="500000" /><item key="LCMS2DPlotMinPointsPerSpectrum" value="2" /><item key="LCMS2DPlotMinIntensity" value="0" /><item key="LCMS2DOverviewPlotDivisor" value="10" /></section></sections>','.D folders that have analysis.yep and extension.baf files; .m folder has EsquireAcquisition.Method file')
INSERT INTO [T_Instrument_Class] VALUES ('BrukerFT_BAF',1,'bruker_ft',0,'','<sections><section name="DatasetQC"><item key="SaveTICAndBPIPlots" value="True" /><item key="SaveLCMS2DPlots" value="True" /><item key="ComputeOverallQualityScores" value="True" /><item key="CreateDatasetInfoFile" value="True" /><item key="LCMS2DPlotMZResolution" value="0.4" /><item key="LCMS2DPlotMaxPointsToPlot" value="500000" /><item key="LCMS2DPlotMinPointsPerSpectrum" value="2" /><item key="LCMS2DPlotMinIntensity" value="0" /><item key="LCMS2DOverviewPlotDivisor" value="10" /></section></sections>','.D folders that have .BAF files and ser or fid files; .m folder has apexAcquisition.method file; used on Bruker 9T, 12T, and 15T')
INSERT INTO [T_Instrument_Class] VALUES ('BRUKERFTMS',1,'zipped_s_folders',1,'No longer used: HMS, HMS-HMSn','<sections><section name="DatasetQC"><item key="SaveTICAndBPIPlots" value="True" /><item key="SaveLCMS2DPlots" value="True" /><item key="ComputeOverallQualityScores" value="True" /><item key="CreateDatasetInfoFile" value="True" /><item key="LCMS2DPlotMZResolution" value="0.4" /><item key="LCMS2DPlotMaxPointsToPlot" value="500000" /><item key="LCMS2DPlotMinPointsPerSpectrum" value="2" /><item key="LCMS2DPlotMinIntensity" value="0" /><item key="LCMS2DOverviewPlotDivisor" value="10" /></section></sections>','Old 9T format')
INSERT INTO [T_Instrument_Class] VALUES ('BrukerMALDI_Imaging',0,'bruker_maldi_imaging',0,'','<sections><section name="DatasetQC"><item key="SaveTICAndBPIPlots" value="True" /><item key="SaveLCMS2DPlots" value="True" /><item key="ComputeOverallQualityScores" value="True" /><item key="CreateDatasetInfoFile" value="True" /><item key="LCMS2DPlotMZResolution" value="0.4" /><item key="LCMS2DPlotMaxPointsToPlot" value="500000" /><item key="LCMS2DPlotMinPointsPerSpectrum" value="2" /><item key="LCMS2DPlotMinIntensity" value="0" /><item key="LCMS2DOverviewPlotDivisor" value="10" /></section></sections>','Series of zipped subfolders, with names like 0_R00X329.zip; Subfolders inside the .Zip files have fid files')
INSERT INTO [T_Instrument_Class] VALUES ('BrukerMALDI_Imaging_V2',1,'bruker_ft',0,'','<sections><section name="DatasetQC"><item key="SaveTICAndBPIPlots" value="True" /><item key="SaveLCMS2DPlots" value="True" /><item key="ComputeOverallQualityScores" value="True" /><item key="CreateDatasetInfoFile" value="True" /><item key="LCMS2DPlotMZResolution" value="0.4" /><item key="LCMS2DPlotMaxPointsToPlot" value="500000" /><item key="LCMS2DPlotMinPointsPerSpectrum" value="2" /><item key="LCMS2DPlotMinIntensity" value="0" /><item key="LCMS2DOverviewPlotDivisor" value="10" /></section></sections>','.D folders that have a large ser file and large .mcf file; .m folder has apexAcquisition.method file')
INSERT INTO [T_Instrument_Class] VALUES ('BrukerMALDI_Spot',1,'bruker_maldi_spot',0,'','<sections><section name="DatasetQC"><item key="SaveTICAndBPIPlots" value="True" /><item key="SaveLCMS2DPlots" value="True" /><item key="ComputeOverallQualityScores" value="True" /><item key="CreateDatasetInfoFile" value="True" /><item key="LCMS2DPlotMZResolution" value="0.4" /><item key="LCMS2DPlotMaxPointsToPlot" value="500000" /><item key="LCMS2DPlotMinPointsPerSpectrum" value="2" /><item key="LCMS2DPlotMinIntensity" value="0" /><item key="LCMS2DOverviewPlotDivisor" value="10" /></section></sections>','Bruker TOF_TOF; folder has a .EMF file and a single sub-folder that has an acqu file and fid file')
INSERT INTO [T_Instrument_Class] VALUES ('BrukerTOF_BAF',1,'bruker_tof_baf',0,'','<sections><section name="DatasetQC"><item key="SaveTICAndBPIPlots" value="True" /><item key="SaveLCMS2DPlots" value="True" /><item key="ComputeOverallQualityScores" value="True" /><item key="CreateDatasetInfoFile" value="True" /><item key="LCMS2DPlotMZResolution" value="0.4" /><item key="LCMS2DPlotMaxPointsToPlot" value="500000" /><item key="LCMS2DPlotMinPointsPerSpectrum" value="2" /><item key="LCMS2DPlotMinIntensity" value="0" /><item key="LCMS2DOverviewPlotDivisor" value="10" /></section></sections>','.D folders from Maxis instrument; have .BAF files but no ser or fid file; .m folder has microTOFQMaxAcquisition.method file')
INSERT INTO [T_Instrument_Class] VALUES ('Data_Folders',0,'data_folders',0,'','','Used for Broker DB analysis jobs')
INSERT INTO [T_Instrument_Class] VALUES ('Finnigan_FTICR',1,'zipped_s_folders',1,'No longer used: HMS, HMS-HMSn','<sections><section name="DatasetQC"><item key="SaveTICAndBPIPlots" value="True" /><item key="SaveLCMS2DPlots" value="True" /><item key="ComputeOverallQualityScores" value="True" /><item key="CreateDatasetInfoFile" value="True" /><item key="LCMS2DPlotMZResolution" value="0.4" /><item key="LCMS2DPlotMaxPointsToPlot" value="500000" /><item key="LCMS2DPlotMinPointsPerSpectrum" value="2" /><item key="LCMS2DPlotMinIntensity" value="0" /><item key="LCMS2DOverviewPlotDivisor" value="10" /></section></sections>','')
INSERT INTO [T_Instrument_Class] VALUES ('Finnigan_Ion_Trap',1,'dot_raw_files',0,'No longer used: MS, MS-MSn, MS-ETD-MSn, MS-CID/ETD-MSn','<sections><section name="DatasetQC"><item key="SaveTICAndBPIPlots" value="True" /><item key="SaveLCMS2DPlots" value="True" /><item key="ComputeOverallQualityScores" value="True" /><item key="CreateDatasetInfoFile" value="True" /><item key="LCMS2DPlotMZResolution" value="0.4" /><item key="LCMS2DPlotMaxPointsToPlot" value="500000" /><item key="LCMS2DPlotMinPointsPerSpectrum" value="2" /><item key="LCMS2DPlotMinIntensity" value="0" /><item key="LCMS2DOverviewPlotDivisor" value="10" /></section></sections>','')
INSERT INTO [T_Instrument_Class] VALUES ('IMS_Agilent_TOF',1,'dot_uimf_files',0,'No longer used: IMS-HMS, IMS-MSn-HMS','<sections><section name="DatasetQC"><item key="SaveTICAndBPIPlots" value="True" /><item key="SaveLCMS2DPlots" value="True" /><item key="ComputeOverallQualityScores" value="True" /><item key="CreateDatasetInfoFile" value="True" /><item key="LCMS2DPlotMZResolution" value="0.4" /><item key="LCMS2DPlotMaxPointsToPlot" value="500000" /><item key="LCMS2DPlotMinPointsPerSpectrum" value="2" /><item key="LCMS2DPlotMinIntensity" value="0" /><item key="LCMS2DOverviewPlotDivisor" value="10" /></section></sections>','')
INSERT INTO [T_Instrument_Class] VALUES ('IMS_Biospect_TOF',0,'biospec_folder',0,'No longer used: IMS-HMS, IMS-MSn-HMS','<sections><section name="DatasetQC"><item key="SaveTICAndBPIPlots" value="True" /><item key="SaveLCMS2DPlots" value="True" /><item key="ComputeOverallQualityScores" value="True" /><item key="CreateDatasetInfoFile" value="True" /><item key="LCMS2DPlotMZResolution" value="0.4" /><item key="LCMS2DPlotMaxPointsToPlot" value="500000" /><item key="LCMS2DPlotMinPointsPerSpectrum" value="2" /><item key="LCMS2DPlotMinIntensity" value="0" /><item key="LCMS2DOverviewPlotDivisor" value="10" /></section></sections>','')
INSERT INTO [T_Instrument_Class] VALUES ('IMS_Sciex_TOF',0,'dot_wiff_files',0,'No longer used: IMS-HMS, IMS-MSn-HMS','<sections><section name="DatasetQC"><item key="SaveTICAndBPIPlots" value="True" /><item key="SaveLCMS2DPlots" value="True" /><item key="ComputeOverallQualityScores" value="True" /><item key="CreateDatasetInfoFile" value="True" /><item key="LCMS2DPlotMZResolution" value="0.4" /><item key="LCMS2DPlotMaxPointsToPlot" value="500000" /><item key="LCMS2DPlotMinPointsPerSpectrum" value="2" /><item key="LCMS2DPlotMinIntensity" value="0" /><item key="LCMS2DOverviewPlotDivisor" value="10" /></section></sections>','')
INSERT INTO [T_Instrument_Class] VALUES ('LTQ_FT',1,'dot_raw_files',0,'No longer used: MS-MSn, HMS, HMS-MSn, HMS-HMSn, HMS-ETD-MSn, HMS-CID/ETD-MSn','<sections><section name="DatasetQC"><item key="SaveTICAndBPIPlots" value="True" /><item key="SaveLCMS2DPlots" value="True" /><item key="ComputeOverallQualityScores" value="True" /><item key="CreateDatasetInfoFile" value="True" /><item key="LCMS2DPlotMZResolution" value="0.4" /><item key="LCMS2DPlotMaxPointsToPlot" value="500000" /><item key="LCMS2DPlotMinPointsPerSpectrum" value="2" /><item key="LCMS2DPlotMinIntensity" value="0" /><item key="LCMS2DOverviewPlotDivisor" value="10" /></section></sections>','')
INSERT INTO [T_Instrument_Class] VALUES ('Micromass_QTOF',0,'dot_raw_folder',0,'No longer used: HMS, HMS-HMSn','<sections><section name="DatasetQC"><item key="SaveTICAndBPIPlots" value="True" /><item key="SaveLCMS2DPlots" value="True" /><item key="ComputeOverallQualityScores" value="True" /><item key="CreateDatasetInfoFile" value="True" /><item key="LCMS2DPlotMZResolution" value="0.4" /><item key="LCMS2DPlotMaxPointsToPlot" value="500000" /><item key="LCMS2DPlotMinPointsPerSpectrum" value="2" /><item key="LCMS2DPlotMinIntensity" value="0" /><item key="LCMS2DOverviewPlotDivisor" value="10" /></section></sections>','')
INSERT INTO [T_Instrument_Class] VALUES ('PrepHPLC',1,'dot_d_folders',0,'','','.D folders that have several .Reg files, a Run.Log file, and a SAMPLE.MAC file')
INSERT INTO [T_Instrument_Class] VALUES ('QStar_QTOF',0,'dot_wiff_files',0,'No longer used: HMS, HMS-HMSn','<sections><section name="DatasetQC"><item key="SaveTICAndBPIPlots" value="True" /><item key="SaveLCMS2DPlots" value="True" /><item key="ComputeOverallQualityScores" value="True" /><item key="CreateDatasetInfoFile" value="True" /><item key="LCMS2DPlotMZResolution" value="0.4" /><item key="LCMS2DPlotMaxPointsToPlot" value="500000" /><item key="LCMS2DPlotMinPointsPerSpectrum" value="2" /><item key="LCMS2DPlotMinIntensity" value="0" /><item key="LCMS2DOverviewPlotDivisor" value="10" /></section></sections>','')
INSERT INTO [T_Instrument_Class] VALUES ('Sciex_QTrap',1,'sciex_wiff_files',0,'','<sections><section name="DatasetQC"><item key="SaveTICAndBPIPlots" value="True" /><item key="SaveLCMS2DPlots" value="True" /><item key="ComputeOverallQualityScores" value="True" /><item key="CreateDatasetInfoFile" value="True" /><item key="LCMS2DPlotMZResolution" value="0.4" /><item key="LCMS2DPlotMaxPointsToPlot" value="500000" /><item key="LCMS2DPlotMinPointsPerSpectrum" value="2" /><item key="LCMS2DPlotMinIntensity" value="0" /><item key="LCMS2DOverviewPlotDivisor" value="10" /></section></sections>','AB Sciex QTrap.  Each dataset has a .wiff file and a .wiff.scan file.')
INSERT INTO [T_Instrument_Class] VALUES ('Sciex_TripleTOF',1,'dot_mzml_files',0,'','<sections><section name="DatasetQC"><item key="SaveTICAndBPIPlots" value="True" /><item key="SaveLCMS2DPlots" value="True" /><item key="ComputeOverallQualityScores" value="True" /><item key="CreateDatasetInfoFile" value="True" /><item key="LCMS2DPlotMZResolution" value="0.4" /><item key="LCMS2DPlotMaxPointsToPlot" value="500000" /><item key="LCMS2DPlotMinPointsPerSpectrum" value="2" /><item key="LCMS2DPlotMinIntensity" value="0" /><item key="LCMS2DOverviewPlotDivisor" value="10" /></section></sections>','AB Sciex TripleTOF.  Original data converted to .mzML format')
INSERT INTO [T_Instrument_Class] VALUES ('Thermo_Exactive',1,'dot_raw_files',0,'No longer used: HMS','<sections><section name="DatasetQC"><item key="SaveTICAndBPIPlots" value="True" /><item key="SaveLCMS2DPlots" value="True" /><item key="ComputeOverallQualityScores" value="True" /><item key="CreateDatasetInfoFile" value="True" /><item key="LCMS2DPlotMZResolution" value="0.4" /><item key="LCMS2DPlotMaxPointsToPlot" value="500000" /><item key="LCMS2DPlotMinPointsPerSpectrum" value="2" /><item key="LCMS2DPlotMinIntensity" value="0" /><item key="LCMS2DOverviewPlotDivisor" value="10" /></section></sections>','')
INSERT INTO [T_Instrument_Class] VALUES ('Triple_Quad',1,'dot_raw_files',0,'No longer used: MS, MS-MSn, MRM','<sections><section name="DatasetQC"><item key="SaveTICAndBPIPlots" value="True" /><item key="SaveLCMS2DPlots" value="True" /><item key="ComputeOverallQualityScores" value="True" /><item key="CreateDatasetInfoFile" value="True" /><item key="LCMS2DPlotMZResolution" value="0.4" /><item key="LCMS2DPlotMaxPointsToPlot" value="500000" /><item key="LCMS2DPlotMinPointsPerSpectrum" value="2" /><item key="LCMS2DPlotMinIntensity" value="0" /><item key="LCMS2DOverviewPlotDivisor" value="10" /></section></sections>','')