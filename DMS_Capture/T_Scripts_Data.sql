/****** Object:  Table [T_Scripts] ******/
/****** RowCount: 5 ******/
SET IDENTITY_INSERT [T_Scripts] ON
INSERT INTO [T_Scripts] (ID, Script, Description, Enabled, Results_Tag, Contents) VALUES (1,'DatasetCapture','This script is for basic dataset capture','Y','CAP','<JobScript Name="DatasetCapture"><Step Number="1" Tool="DatasetCapture" /><Step Number="2" Tool="DatasetIntegrity"><Depends_On Step_Number="1" /></Step><Step Number="3" Tool="DatasetInfo"><Depends_On Step_Number="2" /></Step><Step Number="4" Tool="DatasetQuality"><Depends_On Step_Number="3" /></Step></JobScript>')
INSERT INTO [T_Scripts] (ID, Script, Description, Enabled, Results_Tag, Contents) VALUES (2,'ArchiveUpdate','This script is for updating analysis results folders to archive','Y','CAP','<JobScript Name="ArchiveUpdate"><Step Number="1" Tool="ArchiveUpdate" /></JobScript>')
INSERT INTO [T_Scripts] (ID, Script, Description, Enabled, Results_Tag, Contents) VALUES (3,'DatasetArchive','This script is for initial archive of dataset','Y','DSA','<JobScript Name="DatasetCapture"><Step Number="1" Tool="DatasetArchive" /></JobScript>')
INSERT INTO [T_Scripts] (ID, Script, Description, Enabled, Results_Tag, Contents) VALUES (4,'SourceFileRename','This script is for renaming the source file or folder on the instrument','Y','SFR','<JobScript Name="SourceFileRename"><Step Number="1" Tool="SourceFileRename" /></JobScript>')
INSERT INTO [T_Scripts] (ID, Script, Description, Enabled, Results_Tag, Contents) VALUES (6,'IMSDatasetCapture','This script is for IMS dataset capture','Y','CPI','<JobScript Name="IMSDatasetCapture"><Step Number="1" Tool="DatasetCapture" /><Step Number="2" Tool="DatasetIntegrity"><Depends_On Step_Number="1" /></Step><Step Number="3" Tool="ImsDeMultiplex"><Depends_On Step_Number="2" /></Step><Step Number="4" Tool="DatasetInfo"><Depends_On Step_Number="2" /><Depends_On Step_Number="3" /></Step><Step Number="5" Tool="DatasetQuality"><Depends_On Step_Number="4" /></Step></JobScript>')
SET IDENTITY_INSERT [T_Scripts] OFF
