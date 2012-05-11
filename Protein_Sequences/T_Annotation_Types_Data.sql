/****** Object:  Table [T_Annotation_Types] ******/
/****** RowCount: 29 ******/
SET IDENTITY_INSERT [T_Annotation_Types] ON
INSERT INTO [T_Annotation_Types] (Annotation_Type_ID, TypeName, Description, Example, Authority_ID) VALUES (1,'Locus','TIGR Locus','DR0001',1)
INSERT INTO [T_Annotation_Types] (Annotation_Type_ID, TypeName, Description, Example, Authority_ID) VALUES (2,'Gene Symbol','NCBI Gene Symbol','dnaN',2)
INSERT INTO [T_Annotation_Types] (Annotation_Type_ID, TypeName, Description, Example, Authority_ID) VALUES (3,'Common Name','NCBI Common Name','',2)
INSERT INTO [T_Annotation_Types] (Annotation_Type_ID, TypeName, Description, Example, Authority_ID) VALUES (6,'GI Number','Genbank ID Number','gi|7471825',2)
INSERT INTO [T_Annotation_Types] (Annotation_Type_ID, TypeName, Description, Example, Authority_ID) VALUES (7,'UniParc ID','UniProt Archive ID','Q9RYE8_DEIRA',8)
INSERT INTO [T_Annotation_Types] (Annotation_Type_ID, TypeName, Description, Example, Authority_ID) VALUES (8,'UniProtKB/SwissProt','UniProt Knowledgebase/SwissProt','Q9RYE8_DEIRA',8)
INSERT INTO [T_Annotation_Types] (Annotation_Type_ID, TypeName, Description, Example, Authority_ID) VALUES (10,'Accession Number','GenBank Accession Number','AAF09595.1',2)
INSERT INTO [T_Annotation_Types] (Annotation_Type_ID, TypeName, Description, Example, Authority_ID) VALUES (11,'RefSeq ID','GenBank RefSeq','NP_293727.1',2)
INSERT INTO [T_Annotation_Types] (Annotation_Type_ID, TypeName, Description, Example, Authority_ID) VALUES (12,'PIR ID','Protein Information Resource ID','D75571',8)
INSERT INTO [T_Annotation_Types] (Annotation_Type_ID, TypeName, Description, Example, Authority_ID) VALUES (13,'IPI Number','International Protein Index Number','IPI00015171',4)
INSERT INTO [T_Annotation_Types] (Annotation_Type_ID, TypeName, Description, Example, Authority_ID) VALUES (14,'Other','Oddball things that don''t really fit a major category','',6)
INSERT INTO [T_Annotation_Types] (Annotation_Type_ID, TypeName, Description, Example, Authority_ID) VALUES (16,'IPR Number','Interpro IPR ID','IPR001001',17)
INSERT INTO [T_Annotation_Types] (Annotation_Type_ID, TypeName, Description, Example, Authority_ID) VALUES (17,'Wormpep Accession','Wormpep Accession Number','CE00011',3)
INSERT INTO [T_Annotation_Types] (Annotation_Type_ID, TypeName, Description, Example, Authority_ID) VALUES (18,'Mixed','Name contains multiple annotation types','',7)
INSERT INTO [T_Annotation_Types] (Annotation_Type_ID, TypeName, Description, Example, Authority_ID) VALUES (19,'Unspecified','Annotation source not specified or locally generated','RANI60000',7)
INSERT INTO [T_Annotation_Types] (Annotation_Type_ID, TypeName, Description, Example, Authority_ID) VALUES (20,'CyanoBase ID','ID Number from CyanoBase','SGL0001',18)
INSERT INTO [T_Annotation_Types] (Annotation_Type_ID, TypeName, Description, Example, Authority_ID) VALUES (21,'Contigs','Translated Contiguous Genome Sequences','Contig0.1_19_17904_15715',7)
INSERT INTO [T_Annotation_Types] (Annotation_Type_ID, TypeName, Description, Example, Authority_ID) VALUES (22,'Locus','Locus ID from Joint Genomics Institute','dde_0001',16)
INSERT INTO [T_Annotation_Types] (Annotation_Type_ID, TypeName, Description, Example, Authority_ID) VALUES (23,'Stop-to-Stop','Local Names from Stop-to-Stop database generation','ORF_0011',7)
INSERT INTO [T_Annotation_Types] (Annotation_Type_ID, TypeName, Description, Example, Authority_ID) VALUES (24,'Poxpep ID','ID from Poxvirus Bioinformatics Research Center','MPXV-ZRE_023',14)
INSERT INTO [T_Annotation_Types] (Annotation_Type_ID, TypeName, Description, Example, Authority_ID) VALUES (25,'Stop-to-Start','Proteins from Stop codon to next start codon','',7)
INSERT INTO [T_Annotation_Types] (Annotation_Type_ID, TypeName, Description, Example, Authority_ID) VALUES (26,'Local','Locally generated identification','Sama_0001',7)
INSERT INTO [T_Annotation_Types] (Annotation_Type_ID, TypeName, Description, Example, Authority_ID) VALUES (27,'Locus Name','NCBI Gene Locus Name','pYV0001',2)
INSERT INTO [T_Annotation_Types] (Annotation_Type_ID, TypeName, Description, Example, Authority_ID) VALUES (28,'Locus','Yeast Genome Database Locus','YAL001C',19)
INSERT INTO [T_Annotation_Types] (Annotation_Type_ID, TypeName, Description, Example, Authority_ID) VALUES (29,'Accession Number','TAIR Accession','AT1G01010',20)
INSERT INTO [T_Annotation_Types] (Annotation_Type_ID, TypeName, Description, Example, Authority_ID) VALUES (30,'Mixed','NCBI Annotations with mixed names','gi|78369655|ref|NP_001030383.1|',2)
INSERT INTO [T_Annotation_Types] (Annotation_Type_ID, TypeName, Description, Example, Authority_ID) VALUES (31,'ENSEMBL','Protein description from ENSEMBL database','',9)
INSERT INTO [T_Annotation_Types] (Annotation_Type_ID, TypeName, Description, Example, Authority_ID) VALUES (32,'Sanger','Sequences from the Sanger Institute','LinJ01_0010',3)
INSERT INTO [T_Annotation_Types] (Annotation_Type_ID, TypeName, Description, Example, Authority_ID) VALUES (33,'Trembl ID','Uniprot Trembl ID','tr|A2NTS4',8)
SET IDENTITY_INSERT [T_Annotation_Types] OFF
