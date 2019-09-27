%
% List of all NO sessions that are part of the public data release.
% [please note that many sessions don't exist here because they belong to different experiments]
% 
% urut&acarlson&mfaraut/Jul17
function [NWBsessions, NWB_listOf_allUsable] = defineNWBsessions_release()

NWBsessions=[];  % struct of all sessions

%P9S1 same day
c=5; 
NWBsessions(c).session='P9HMH_032306'; 
NWBsessions(c).sessionID='P9S1';
NWBsessions(c).EXPERIMENTIDLearn=80; % Learning block trials in eventRaw.mat file
NWBsessions(c).EXPERIMENTIDRecog=81; % Memory test block trials in eventRaw.mat file
NWBsessions(c).taskDescr='NO';   % folder name in which data are stored (in 'events' and 'sorted' folders)
NWBsessions(c).variant=1;            % 3 variants of the experiment corresponding to 3 sets of stimuli (cf. Table 4)
NWBsessions(c).blockIDLearn=1;       % used to load the stimuli numbers for the Learning block
NWBsessions(c).blockIDRecog=2;       % used to load the stimuli numbers for the Memory block
NWBsessions(c).patient_nb=1;         % patient number
NWBsessions(c).patientsession=1;     % rank of the session for a given patient (if a same patient did the task more than ones)
NWBsessions(c).diagnosisCode=1;     % location of epileptic focal point: 0)not localized 1)Right Mesial Temporal 2)Left Mesial Temporal 3)Right Neocortical Temporal 4)Left Neocortical Temporal 5)Right Lateral Frontal 6)Left Lateral Frontal 7)Bilateral Independent Temporal 8)Bilateral Independent Frontal 9)Right Other 10)Left Other

%P9S3. same day.
c=6;
NWBsessions(c).session='P9HMH_032506';
NWBsessions(c).sessionID='P9S3';
NWBsessions(c).EXPERIMENTIDLearn=83;
NWBsessions(c).EXPERIMENTIDRecog=84;
NWBsessions(c).taskDescr='NO';
NWBsessions(c).variant=2;
NWBsessions(c).blockIDLearn=1; 
NWBsessions(c).blockIDRecog=2; 
NWBsessions(c).phaseShiftCorrection=0; 
NWBsessions(c).patient_nb=1;
NWBsessions(c).patientsession=2;
NWBsessions(c).diagnosisCode=1;

%P10S2 same day
c=7;
NWBsessions(c).session='P10HMH_092206';
NWBsessions(c).sessionID='P10S2';
NWBsessions(c).EXPERIMENTIDLearn=80;
NWBsessions(c).EXPERIMENTIDRecog=81;
NWBsessions(c).taskDescr='NO';
NWBsessions(c).variant=1;
NWBsessions(c).blockIDLearn=1; 
NWBsessions(c).blockIDRecog=2; 
NWBsessions(c).phaseShiftCorrection=0; 
NWBsessions(c).patient_nb=2;
NWBsessions(c).patientsession=1;
NWBsessions(c).diagnosisCode=6;

%P11S1 NO same day
c=9;
NWBsessions(c).session='P11HMH_110906';
NWBsessions(c).sessionID='P11S1';
NWBsessions(c).EXPERIMENTIDLearn=80;
NWBsessions(c).EXPERIMENTIDRecog=81;
NWBsessions(c).taskDescr='NO';
NWBsessions(c).variant=1;
NWBsessions(c).blockIDLearn=1; 
NWBsessions(c).blockIDRecog=2; 
NWBsessions(c).patient_nb=3;
NWBsessions(c).patientsession=1;
NWBsessions(c).diagnosisCode=5;

%P14S1. same day.
c=17;
NWBsessions(c).session='P14HMH_062107';
NWBsessions(c).sessionID='P14S1';
NWBsessions(c).EXPERIMENTIDLearn=83;
NWBsessions(c).EXPERIMENTIDRecog=84;
NWBsessions(c).taskDescr='NO';
NWBsessions(c).variant=2;
NWBsessions(c).blockIDLearn=1; 
NWBsessions(c).blockIDRecog=2; 
NWBsessions(c).phaseShiftCorrection=1; 
NWBsessions(c).patient_nb=4;
NWBsessions(c).patientsession=1;
NWBsessions(c).diagnosisCode=7;

%P14S2. same day. (reduced)
c=18;
NWBsessions(c).session='P14HMH_062307';
NWBsessions(c).sessionID='P14S2';
NWBsessions(c).EXPERIMENTIDLearn=80;
NWBsessions(c).EXPERIMENTIDRecog=81;
NWBsessions(c).taskDescr='NO';
NWBsessions(c).variant=1;
NWBsessions(c).blockIDLearn=1; 
NWBsessions(c).blockIDRecog=2; 
NWBsessions(c).phaseShiftCorrection=1; 
NWBsessions(c).patient_nb=4;
NWBsessions(c).patientsession=2;
NWBsessions(c).diagnosisCode=7;

%P15S1. same day.
c=20;
NWBsessions(c).session='P15HMH_091307';
NWBsessions(c).sessionID='P15S1';
NWBsessions(c).EXPERIMENTIDLearn=80;
NWBsessions(c).EXPERIMENTIDRecog=81;
NWBsessions(c).taskDescr='NO';
NWBsessions(c).variant=1;
NWBsessions(c).blockIDLearn=1; 
NWBsessions(c).blockIDRecog=2; 
NWBsessions(c).phaseShiftCorrection=0; 
NWBsessions(c).patient_nb=5;
NWBsessions(c).patientsession=1;
NWBsessions(c).diagnosisCode=1;

%P15S2. same day.
c=21;
NWBsessions(c).session='P15HMH_091407';
NWBsessions(c).sessionID='P15S2';
NWBsessions(c).EXPERIMENTIDLearn=83;
NWBsessions(c).EXPERIMENTIDRecog=84;
NWBsessions(c).taskDescr='NO';
NWBsessions(c).variant=2;
NWBsessions(c).blockIDLearn=1; 
NWBsessions(c).blockIDRecog=2; 
NWBsessions(c).patient_nb=5;
NWBsessions(c).patientsession=2;
NWBsessions(c).diagnosisCode=1;

%P16S1. same day.
% Skip because the event data do not have 100 events
% c=23;
% NWBsessions(c).session='P16HMH_101207';
% NWBsessions(c).sessionID='P16S1';
% NWBsessions(c).EXPERIMENTIDLearn=83;
% NWBsessions(c).EXPERIMENTIDRecog=84;
% NWBsessions(c).taskDescr='NO';
% NWBsessions(c).variant=2;
% NWBsessions(c).blockIDLearn=1; 
% NWBsessions(c).blockIDRecog=2; 
% NWBsessions(c).phaseShiftCorrection=1; 
% NWBsessions(c).patient_nb=6;
% NWBsessions(c).patientsession=1;
% NWBsessions(c).diagnosisCode=5;

%P16S2. same day.
c=24;
NWBsessions(c).session='P16HMH_101507';
NWBsessions(c).sessionID='P16S2';
NWBsessions(c).EXPERIMENTIDLearn=80;
NWBsessions(c).EXPERIMENTIDRecog=81;
NWBsessions(c).taskDescr='NO';
NWBsessions(c).variant=1;
NWBsessions(c).blockIDLearn=1; 
NWBsessions(c).blockIDRecog=2; 
NWBsessions(c).phaseShiftCorrection=1; %sort on raw, LFP on rawLFP. 
NWBsessions(c).patient_nb=6;
NWBsessions(c).patientsession=2;
NWBsessions(c).diagnosisCode=5;

%P18S2. same day. (reduced)
c=26;
NWBsessions(c).session='P18HMH_061608';
NWBsessions(c).sessionID='P18S2';
NWBsessions(c).EXPERIMENTIDLearn=80;
NWBsessions(c).EXPERIMENTIDRecog=81;
NWBsessions(c).taskDescr='NO';
NWBsessions(c).variant=1;
NWBsessions(c).blockIDLearn=1; 
NWBsessions(c).blockIDRecog=2; 
NWBsessions(c).phaseShiftCorrection=1; 
NWBsessions(c).patient_nb=7;
NWBsessions(c).patientsession=1;
NWBsessions(c).diagnosisCode=1;

%P19S1. same day. (reduced)
c=27;
NWBsessions(c).session='P19HMH_062608';
NWBsessions(c).sessionID='P19S1';
NWBsessions(c).EXPERIMENTIDLearn=83;
NWBsessions(c).EXPERIMENTIDRecog=84;
NWBsessions(c).taskDescr='NO';
NWBsessions(c).variant=2;
NWBsessions(c).blockIDLearn=1; 
NWBsessions(c).blockIDRecog=2; 
NWBsessions(c).phaseShiftCorrection=1; 
NWBsessions(c).patient_nb=8;
NWBsessions(c).patientsession=1;
NWBsessions(c).diagnosisCode=6;

%P19S2. same day. 
c=28;
NWBsessions(c).session='P19HMH_062708';
NWBsessions(c).sessionID='P19S2';
NWBsessions(c).EXPERIMENTIDLearn=80;
NWBsessions(c).EXPERIMENTIDRecog=81;
NWBsessions(c).taskDescr='NO';
NWBsessions(c).variant=1;
NWBsessions(c).blockIDLearn=1; 
NWBsessions(c).blockIDRecog=2; 
NWBsessions(c).phaseShiftCorrection=1; 
NWBsessions(c).patient_nb=8;
NWBsessions(c).patientsession=2;
NWBsessions(c).diagnosisCode=6;

%P17S1. same day. (reduced)
c=32;
NWBsessions(c).session='P17HMH_052208';
NWBsessions(c).sessionID='P17S1';
NWBsessions(c).EXPERIMENTIDLearn=80;
NWBsessions(c).EXPERIMENTIDRecog=81;
NWBsessions(c).taskDescr='NO';
NWBsessions(c).variant=1;
NWBsessions(c).blockIDLearn=1; 
NWBsessions(c).blockIDRecog=2; 
NWBsessions(c).phaseShiftCorrection=1; 
NWBsessions(c).patient_nb=9;
NWBsessions(c).patientsession=1;
NWBsessions(c).diagnosisCode=6;

%P21S1 NO2 same day
c=38;
NWBsessions(c).session='P21HMH_012209';
NWBsessions(c).sessionID='P21S1';
NWBsessions(c).EXPERIMENTIDLearn=83;
NWBsessions(c).EXPERIMENTIDRecog=84;
NWBsessions(c).taskDescr='NO2';
NWBsessions(c).variant=2;
NWBsessions(c).blockIDLearn=1; 
NWBsessions(c).blockIDRecog=2; 
NWBsessions(c).patient_nb=10;
NWBsessions(c).patientsession=1;
NWBsessions(c).diagnosisCode=0;

%P21S1 NO1 same day
c=39;
NWBsessions(c).session='P21HMH_012209';
NWBsessions(c).sessionID='P21S1';
NWBsessions(c).EXPERIMENTIDLearn=80;
NWBsessions(c).EXPERIMENTIDRecog=81;
NWBsessions(c).taskDescr='NO1';
NWBsessions(c).variant=1;
NWBsessions(c).blockIDLearn=1; 
NWBsessions(c).blockIDRecog=2; 
NWBsessions(c).patient_nb=10;
NWBsessions(c).patientsession=2;
NWBsessions(c).diagnosisCode=0;

%P21S2 NO3 same day 
c=41;
NWBsessions(c).session='P21HMH_012309';
NWBsessions(c).sessionID='P21S2';
NWBsessions(c).EXPERIMENTIDLearn=88;
NWBsessions(c).EXPERIMENTIDRecog=89;
NWBsessions(c).taskDescr='NO';
NWBsessions(c).variant=3;
NWBsessions(c).blockIDLearn=1; 
NWBsessions(c).blockIDRecog=2; 
NWBsessions(c).patient_nb=10;
NWBsessions(c).patientsession=3;
NWBsessions(c).diagnosisCode=0;

%P23S2 NO3 same day
c=43;
NWBsessions(c).session='P23HMH_022109';
NWBsessions(c).sessionID='P23S2';
NWBsessions(c).EXPERIMENTIDLearn=88;
NWBsessions(c).EXPERIMENTIDRecog=89;
NWBsessions(c).taskDescr='NO';
NWBsessions(c).variant=3;
NWBsessions(c).blockIDLearn=1; 
NWBsessions(c).blockIDRecog=2; 
NWBsessions(c).patient_nb=11;
NWBsessions(c).patientsession=1;
NWBsessions(c).diagnosisCode=2;

%P23S2 NO2 same day (reduced -- 50 learning trials)
c=44;
NWBsessions(c).session='P23HMH_022109';
NWBsessions(c).sessionID='P23S2';
NWBsessions(c).EXPERIMENTIDLearn=83;
NWBsessions(c).EXPERIMENTIDRecog=84;
NWBsessions(c).taskDescr='NO';
NWBsessions(c).variant=2;
NWBsessions(c).blockIDLearn=1; 
NWBsessions(c).blockIDRecog=2; 
NWBsessions(c).patient_nb=11;
NWBsessions(c).patientsession=2;
NWBsessions(c).diagnosisCode=2;

%P23S4 NO1 same day
c=47;
NWBsessions(c).session='P23HMH_022309';
NWBsessions(c).sessionID='P23S4';
NWBsessions(c).EXPERIMENTIDLearn=80;
NWBsessions(c).EXPERIMENTIDRecog=81;
NWBsessions(c).taskDescr='NO';
NWBsessions(c).variant=1;
NWBsessions(c).blockIDLearn=1; 
NWBsessions(c).blockIDRecog=2; 
NWBsessions(c).patient_nb=11;
NWBsessions(c).patientsession=3;
NWBsessions(c).diagnosisCode=2;

%P28 HMH, 031310
c=48;
NWBsessions(c).session='P28HMH';
NWBsessions(c).sessionID='P28S2';
NWBsessions(c).EXPERIMENTIDLearn=88;
NWBsessions(c).EXPERIMENTIDRecog=89;
NWBsessions(c).taskDescr='NO';
NWBsessions(c).variant=3;
NWBsessions(c).blockIDLearn=1; 
NWBsessions(c).blockIDRecog=2; 
NWBsessions(c).patient_nb=12;
NWBsessions(c).patientsession=1;
NWBsessions(c).diagnosisCode=1;

%P29 HMH, 121810
c=49;
NWBsessions(c).session='P29HMH';
NWBsessions(c).sessionID='P29S2';
NWBsessions(c).EXPERIMENTIDLearn=88;
NWBsessions(c).EXPERIMENTIDRecog=89;
NWBsessions(c).taskDescr='NO';
NWBsessions(c).variant=3;
NWBsessions(c).blockIDLearn=1; 
NWBsessions(c).blockIDRecog=2; 
NWBsessions(c).patient_nb=13;
NWBsessions(c).patientsession=1;
NWBsessions(c).diagnosisCode=10;

%P31 HMH, 042611
c=50;
NWBsessions(c).session='P31HMH';
NWBsessions(c).sessionID='P31';
NWBsessions(c).EXPERIMENTIDLearn=83;
NWBsessions(c).EXPERIMENTIDRecog=84;
NWBsessions(c).taskDescr='NO';
NWBsessions(c).variant=2;
NWBsessions(c).blockIDLearn=1; 
NWBsessions(c).blockIDRecog=2; 
NWBsessions(c).patient_nb=14;
NWBsessions(c).patientsession=1;
NWBsessions(c).diagnosisCode=1;

%P33 HMH, 072011
c=52;
NWBsessions(c).session='P33HMH';
NWBsessions(c).sessionID='P33S2';
NWBsessions(c).EXPERIMENTIDLearn=80;
NWBsessions(c).EXPERIMENTIDRecog=81;
NWBsessions(c).taskDescr='NO';
NWBsessions(c).variant=1;
NWBsessions(c).blockIDLearn=1; 
NWBsessions(c).blockIDRecog=2; 
NWBsessions(c).patient_nb=15;
NWBsessions(c).patientsession=1;
NWBsessions(c).diagnosisCode=2;

%P42 HMH, 033013
c=54;
NWBsessions(c).session='P42HMH';
NWBsessions(c).sessionID='P42';
NWBsessions(c).EXPERIMENTIDLearn=80;
NWBsessions(c).EXPERIMENTIDRecog=81;  %Also has 82, same day
NWBsessions(c).taskDescr='NO';
NWBsessions(c).variant=1;
NWBsessions(c).blockIDLearn=1; 
NWBsessions(c).blockIDRecog=2; 
NWBsessions(c).patient_nb=16;
NWBsessions(c).patientsession=1;
NWBsessions(c).diagnosisCode=0;

%P42 HMH, 033013; second block (same day)
c=55;
NWBsessions(c).session='P42HMH';
NWBsessions(c).sessionID='P42';
NWBsessions(c).EXPERIMENTIDLearn=80;
NWBsessions(c).EXPERIMENTIDRecog=82;  
NWBsessions(c).taskDescr='NO';
NWBsessions(c).variant=1;
NWBsessions(c).blockIDLearn=1; 
NWBsessions(c).blockIDRecog=3; 
NWBsessions(c).patient_nb=16;
NWBsessions(c).patientsession=2;
NWBsessions(c).diagnosisCode=0;

%P43S1 HMH, 041213
c=56;
NWBsessions(c).session='P43HMH_S2';
NWBsessions(c).sessionID='P43S1';
NWBsessions(c).EXPERIMENTIDLearn=80;
NWBsessions(c).EXPERIMENTIDRecog=81;  
NWBsessions(c).taskDescr='NO';
NWBsessions(c).variant=1;
NWBsessions(c).blockIDLearn=1; 
NWBsessions(c).blockIDRecog=2; 
NWBsessions(c).patient_nb=17;
NWBsessions(c).patientsession=1;
NWBsessions(c).diagnosisCode=2;

%P27 (KF), 022310
c=58;
NWBsessions(c).session='P27HMH_022310';
NWBsessions(c).sessionID='P27S2';
NWBsessions(c).EXPERIMENTIDLearn=83;
NWBsessions(c).EXPERIMENTIDRecog=84;  
NWBsessions(c).taskDescr='NO';
NWBsessions(c).variant=2;
NWBsessions(c).blockIDLearn=1; 
NWBsessions(c).blockIDRecog=2; 
NWBsessions(c).patient_nb=18;
NWBsessions(c).patientsession=1;
NWBsessions(c).diagnosisCode=7;

%P24CS, session1
c=59;
NWBsessions(c).session='P24CS_091912';
NWBsessions(c).sessionID='P24CSS2';
NWBsessions(c).EXPERIMENTIDLearn=80;
NWBsessions(c).EXPERIMENTIDRecog=81;  
NWBsessions(c).taskDescr='NO';
NWBsessions(c).variant=1;
NWBsessions(c).blockIDLearn=1; 
NWBsessions(c).blockIDRecog=2; 
NWBsessions(c).patient_nb=19;
NWBsessions(c).patientsession=1;
NWBsessions(c).diagnosisCode=0;

%P24CS, session2
c=60;
NWBsessions(c).session='P24CS_092112';
NWBsessions(c).sessionID='P24CSS2';
NWBsessions(c).EXPERIMENTIDLearn=83;
NWBsessions(c).EXPERIMENTIDRecog=84;  
NWBsessions(c).taskDescr='NO';
NWBsessions(c).variant=2;
NWBsessions(c).blockIDLearn=1; 
NWBsessions(c).blockIDRecog=2; 
NWBsessions(c).patient_nb=19;
NWBsessions(c).patientsession=2;
NWBsessions(c).diagnosisCode=0;

%P25CS, session1
c=61;
NWBsessions(c).session='P25CS_092712';
NWBsessions(c).sessionID='P25CSS1';
NWBsessions(c).EXPERIMENTIDLearn=80;
NWBsessions(c).EXPERIMENTIDRecog=81;  
NWBsessions(c).taskDescr='NO';
NWBsessions(c).variant=1;
NWBsessions(c).blockIDLearn=1; 
NWBsessions(c).blockIDRecog=2; 
NWBsessions(c).patient_nb=20;
NWBsessions(c).patientsession=1;
NWBsessions(c).diagnosisCode=7;

%P25CS, session2
c=63;
NWBsessions(c).session='P25CS_092812';
NWBsessions(c).sessionID='P25CSS2';
NWBsessions(c).EXPERIMENTIDLearn=83;
NWBsessions(c).EXPERIMENTIDRecog=84;  
NWBsessions(c).taskDescr='NO';
NWBsessions(c).variant=2;
NWBsessions(c).blockIDLearn=1; 
NWBsessions(c).blockIDRecog=2; 
NWBsessions(c).patient_nb=20;
NWBsessions(c).patientsession=2;
NWBsessions(c).diagnosisCode=7;

%P26CS, session1
c=64;
NWBsessions(c).session='P26CS_121112';
NWBsessions(c).sessionID='P26CSS1';
NWBsessions(c).EXPERIMENTIDLearn=80;
NWBsessions(c).EXPERIMENTIDRecog=81;  
NWBsessions(c).taskDescr='NO';
NWBsessions(c).variant=1;
NWBsessions(c).blockIDLearn=1; 
NWBsessions(c).blockIDRecog=2; 
NWBsessions(c).patient_nb=21;
NWBsessions(c).patientsession=1;
NWBsessions(c).diagnosisCode=2;

%P26CS, session3
c=66;
NWBsessions(c).session='P26CS_121412';
NWBsessions(c).sessionID='P26CSS3';
NWBsessions(c).EXPERIMENTIDLearn=83;
NWBsessions(c).EXPERIMENTIDRecog=84;  
NWBsessions(c).taskDescr='NO';
NWBsessions(c).variant=2;
NWBsessions(c).blockIDLearn=1; 
NWBsessions(c).blockIDRecog=2; 
NWBsessions(c).patient_nb=21;
NWBsessions(c).patientsession=2;
NWBsessions(c).diagnosisCode=2;

%P27CS, session1
c=67;
NWBsessions(c).session='P27CS_011913';
NWBsessions(c).sessionID='P27CSS1';
NWBsessions(c).EXPERIMENTIDLearn=80;
NWBsessions(c).EXPERIMENTIDRecog=81;  
NWBsessions(c).taskDescr='NO';
NWBsessions(c).variant=1;
NWBsessions(c).blockIDLearn=1; 
NWBsessions(c).blockIDRecog=2; 
NWBsessions(c).patient_nb=22;
NWBsessions(c).patientsession=1;
NWBsessions(c).diagnosisCode=2;

%P44 HMH, 
c=68;
NWBsessions(c).session='P44HMH_s3';
NWBsessions(c).sessionID='P44HMHs3';
NWBsessions(c).EXPERIMENTIDLearn=80;
NWBsessions(c).EXPERIMENTIDRecog=81;  
NWBsessions(c).taskDescr='NO';
NWBsessions(c).variant=1;
NWBsessions(c).blockIDLearn=1; 
NWBsessions(c).blockIDRecog=2; 
NWBsessions(c).patient_nb=23;
NWBsessions(c).patientsession=1;
NWBsessions(c).diagnosisCode=1;

%P29CS, s1
c=69;
NWBsessions(c).session='P29CS_103013';
NWBsessions(c).sessionID='P29CSs1';
NWBsessions(c).EXPERIMENTIDLearn=80;
NWBsessions(c).EXPERIMENTIDRecog=81;  
NWBsessions(c).taskDescr='NO';
NWBsessions(c).variant=1;
NWBsessions(c).blockIDLearn=1; 
NWBsessions(c).blockIDRecog=2; 
NWBsessions(c).patient_nb=24;
NWBsessions(c).patientsession=1;
NWBsessions(c).diagnosisCode=4;

%P29CS, s2, with eye tracking
c=70;
NWBsessions(c).session='P29CS_103113';
NWBsessions(c).sessionID='P29CSs2';
NWBsessions(c).EXPERIMENTIDLearn=80;
NWBsessions(c).EXPERIMENTIDRecog=81;  
NWBsessions(c).taskDescr='NO';
NWBsessions(c).variant=2;
NWBsessions(c).blockIDLearn=1; 
NWBsessions(c).blockIDRecog=2; 
NWBsessions(c).patient_nb=24;
NWBsessions(c).patientsession=2;
NWBsessions(c).diagnosisCode=4;

%var3, no eye track
c=73;
NWBsessions(c).session='P31CS_020314';
NWBsessions(c).sessionID='P31CSs2';
NWBsessions(c).EXPERIMENTIDLearn=80;
NWBsessions(c).EXPERIMENTIDRecog=81;  
NWBsessions(c).taskDescr='NO';
NWBsessions(c).variant=3;
NWBsessions(c).blockIDLearn=1; 
NWBsessions(c).blockIDRecog=2; 
NWBsessions(c).patient_nb=25;
NWBsessions(c).patientsession=1;
NWBsessions(c).diagnosisCode=4;

%var2, no eye track
c=74;
NWBsessions(c).session='P32CS_021314';
NWBsessions(c).sessionID='P32CSs1';
NWBsessions(c).EXPERIMENTIDLearn=80;
NWBsessions(c).EXPERIMENTIDRecog=81;  
NWBsessions(c).taskDescr='NO';
NWBsessions(c).variant=2;
NWBsessions(c).blockIDLearn=1; 
NWBsessions(c).blockIDRecog=2; 
NWBsessions(c).patient_nb=26;
NWBsessions(c).patientsession=1;
NWBsessions(c).diagnosisCode=0;

%var3, no eye track
c=76;
NWBsessions(c).session='P33CS_032714';
NWBsessions(c).sessionID='P33CS';
NWBsessions(c).EXPERIMENTIDLearn=83;
NWBsessions(c).EXPERIMENTIDRecog=84;  
NWBsessions(c).taskDescr='NO3';
NWBsessions(c).variant=3;
NWBsessions(c).blockIDLearn=1; 
NWBsessions(c).blockIDRecog=2; 
NWBsessions(c).patient_nb=27;
NWBsessions(c).patientsession=1;
NWBsessions(c).diagnosisCode=1;

%var2, no eye track
c=77;
NWBsessions(c).session='P33CS_032714';
NWBsessions(c).sessionID='P33CS';
NWBsessions(c).EXPERIMENTIDLearn=81;
NWBsessions(c).EXPERIMENTIDRecog=82;  
NWBsessions(c).taskDescr='NO2';
NWBsessions(c).variant=2;
NWBsessions(c).blockIDLearn=1; 
NWBsessions(c).blockIDRecog=2; 
NWBsessions(c).patient_nb=27;
NWBsessions(c).patientsession=2;
NWBsessions(c).diagnosisCode=1;

%var1, same day, with ET
c=78;
NWBsessions(c).session='P33CS_033014';
NWBsessions(c).sessionID='P33CS';
NWBsessions(c).EXPERIMENTIDLearn=80;
NWBsessions(c).EXPERIMENTIDRecog=81;  
NWBsessions(c).taskDescr='NO';
NWBsessions(c).variant=1;
NWBsessions(c).blockIDLearn=1; 
NWBsessions(c).blockIDRecog=2; 
NWBsessions(c).patient_nb=27;
NWBsessions(c).patientsession=3;
NWBsessions(c).diagnosisCode=1;

%NOvar3, with ET
c=85;
NWBsessions(c).session='P34CS_121414';
NWBsessions(c).sessionID='P34CS';
NWBsessions(c).EXPERIMENTIDLearn=83;
NWBsessions(c).EXPERIMENTIDRecog=84;  
NWBsessions(c).taskDescr='NO';
NWBsessions(c).variant=3;
NWBsessions(c).blockIDLearn=1; 
NWBsessions(c).blockIDRecog=2; 
NWBsessions(c).patient_nb=28;
NWBsessions(c).patientsession=1;
NWBsessions(c).diagnosisCode=7;

%var1, NO P47HMH, no ET
c=92;
NWBsessions(c).session='P47HMH_062014';
NWBsessions(c).sessionID='P47HMH';
NWBsessions(c).EXPERIMENTIDLearn=80;
NWBsessions(c).EXPERIMENTIDRecog=81;  
NWBsessions(c).taskDescr='NO';
NWBsessions(c).variant=1;
NWBsessions(c).blockIDLearn=1; 
NWBsessions(c).blockIDRecog=2; 
NWBsessions(c).patient_nb=29;
NWBsessions(c).patientsession=1;
NWBsessions(c).diagnosisCode=1;

%NO P39CS, var1, with eye track
c=93;
NWBsessions(c).session='P39CS_081515';
NWBsessions(c).sessionID='P39CS';
NWBsessions(c).EXPERIMENTIDLearn=80;
NWBsessions(c).EXPERIMENTIDRecog=81;  
NWBsessions(c).taskDescr='NO';
NWBsessions(c).variant=1;
NWBsessions(c).blockIDLearn=1; 
NWBsessions(c).blockIDRecog=2; 
NWBsessions(c).patient_nb=30;
NWBsessions(c).patientsession=1;
NWBsessions(c).diagnosisCode=9;

%NO P37CS, var3, no eye track
c=96;
NWBsessions(c).session='P37CS_032515';
NWBsessions(c).sessionID='P37CS';
NWBsessions(c).EXPERIMENTIDLearn=80;
NWBsessions(c).EXPERIMENTIDRecog=81;  
NWBsessions(c).taskDescr='NO';
NWBsessions(c).variant=3;
NWBsessions(c).blockIDLearn=1; 
NWBsessions(c).blockIDRecog=2;
NWBsessions(c).patient_nb=31;
NWBsessions(c).patientsession=1;
NWBsessions(c).diagnosisCode=1;

% NO P47HMH, var3 no ET
c=97;
NWBsessions(c).session='P47HMH_062214';
NWBsessions(c).sessionID='P47HMH';
NWBsessions(c).EXPERIMENTIDLearn=80;
NWBsessions(c).EXPERIMENTIDRecog=81;  
NWBsessions(c).taskDescr='NO';
NWBsessions(c).variant=3;
NWBsessions(c).blockIDLearn=1; 
NWBsessions(c).blockIDRecog=2; 
NWBsessions(c).patient_nb=29;
NWBsessions(c).patientsession=2;
NWBsessions(c).diagnosisCode=1;


% NO P48 HMH var 2
% Skipped because the event data do not have 100 events
% c = 98;
% NWBsessions(c).session='P48HMH_122014';
% NWBsessions(c).sessionID='P48HMH';
% NWBsessions(c).EXPERIMENTIDLearn=82;
% NWBsessions(c).EXPERIMENTIDRecog=83;  
% NWBsessions(c).taskDescr='NO2';
% NWBsessions(c).variant=2;
% NWBsessions(c).blockIDLearn=1; 
% NWBsessions(c).blockIDRecog=2; 
% NWBsessions(c).patient_nb=32;
% NWBsessions(c).patientsession=1;
% NWBsessions(c).diagnosisCode=2;

% NO P48 HMH var 1
% c=99;
% NWBsessions(c).session='P48HMH_122014';
% NWBsessions(c).sessionID='P48HMH';
% NWBsessions(c).EXPERIMENTIDLearn=80;
% NWBsessions(c).EXPERIMENTIDRecog=81;  
% NWBsessions(c).taskDescr='NO1';
% NWBsessions(c).variant=1;
% NWBsessions(c).blockIDLearn=1; 
% NWBsessions(c).blockIDRecog=2; 
% NWBsessions(c).patient_nb=32;
% NWBsessions(c).patientsession=2;
% NWBsessions(c).diagnosisCode=2;


%NO P39CS, var3
c=100;
NWBsessions(c).session='P39CS_080515';
NWBsessions(c).sessionID='P39CS';
NWBsessions(c).EXPERIMENTIDLearn=82;
NWBsessions(c).EXPERIMENTIDRecog=83;  
NWBsessions(c).taskDescr='NO';
NWBsessions(c).variant=3;
NWBsessions(c).blockIDLearn=1; 
NWBsessions(c).blockIDRecog=2;
NWBsessions(c).patient_nb=30;
NWBsessions(c).patientsession=2;
NWBsessions(c).diagnosisCode=9;

%NO P40CS, var3
c=101;
NWBsessions(c).session='P40CS_010916';
NWBsessions(c).sessionID='P40CS';
NWBsessions(c).EXPERIMENTIDLearn=80;
NWBsessions(c).EXPERIMENTIDRecog=81;  
NWBsessions(c).taskDescr='NO';
NWBsessions(c).variant=3;
NWBsessions(c).blockIDLearn=1; 
NWBsessions(c).blockIDRecog=2;
NWBsessions(c).patient_nb=33;
NWBsessions(c).patientsession=1;
NWBsessions(c).diagnosisCode=9;

%NO P38CS, var3
c=102;
NWBsessions(c).session='P38CS_070115';
NWBsessions(c).sessionID='P38CS';
NWBsessions(c).EXPERIMENTIDLearn=80;
NWBsessions(c).EXPERIMENTIDRecog=81;  
NWBsessions(c).taskDescr='NO';
NWBsessions(c).variant=3;
NWBsessions(c).blockIDLearn=1; 
NWBsessions(c).blockIDRecog=2;
NWBsessions(c).patient_nb=34;
NWBsessions(c).patientsession=1;
NWBsessions(c).diagnosisCode=1;

%NO P51HMH, var3
c=104;
NWBsessions(c).session='P51HMH_021516';
NWBsessions(c).sessionID='P51HMH';
NWBsessions(c).EXPERIMENTIDLearn=80;
NWBsessions(c).EXPERIMENTIDRecog=81;  
NWBsessions(c).taskDescr='NO';
NWBsessions(c).variant=3;
NWBsessions(c).blockIDLearn=1; 
NWBsessions(c).blockIDRecog=2;
NWBsessions(c).patient_nb=35;
NWBsessions(c).patientsession=1;
NWBsessions(c).diagnosisCode=8;

%NO P51HMH, var 1
c=105;
NWBsessions(c).session='P51HMH_021416';
NWBsessions(c).sessionID='P51HMH';
NWBsessions(c).EXPERIMENTIDLearn=82;
NWBsessions(c).EXPERIMENTIDRecog=83;  
NWBsessions(c).taskDescr='NO';
NWBsessions(c).variant=1;
NWBsessions(c).blockIDLearn=1; 
NWBsessions(c).blockIDRecog=2; 
NWBsessions(c).patient_nb=35;
NWBsessions(c).patientsession=2;
NWBsessions(c).diagnosisCode=8;

%NO P42CS, var1
c=111;
NWBsessions(c).session='P42CS_081416';
NWBsessions(c).sessionID='P42CS';
NWBsessions(c).EXPERIMENTIDLearn=80;
NWBsessions(c).EXPERIMENTIDRecog=81;  
NWBsessions(c).taskDescr='NO';
NWBsessions(c).variant=1;
NWBsessions(c).blockIDLearn=1; 
NWBsessions(c).blockIDRecog=2;
NWBsessions(c).patient_nb=36;
NWBsessions(c).patientsession=1;
NWBsessions(c).diagnosisCode=0;

%NO P42CS, var2
c=112;
NWBsessions(c).session='P42CS_081516';
NWBsessions(c).sessionID='P42CS';
NWBsessions(c).EXPERIMENTIDLearn=80;
NWBsessions(c).EXPERIMENTIDRecog=81;  
NWBsessions(c).taskDescr='NO';
NWBsessions(c).variant=2;
NWBsessions(c).blockIDLearn=1; 
NWBsessions(c).blockIDRecog=2;
NWBsessions(c).patient_nb=36;
NWBsessions(c).patientsession=2;
NWBsessions(c).diagnosisCode=0;

%NO P43CS, var3
c=113;
NWBsessions(c).session='P43CS_110316';
NWBsessions(c).sessionID='P43CS';
NWBsessions(c).EXPERIMENTIDLearn=80;
NWBsessions(c).EXPERIMENTIDRecog=81;  
NWBsessions(c).taskDescr='NO';
NWBsessions(c).variant=3;
NWBsessions(c).blockIDLearn=1; 
NWBsessions(c).blockIDRecog=2;
NWBsessions(c).patient_nb=37;
NWBsessions(c).patientsession=1;
NWBsessions(c).diagnosisCode=2;

%NO P44CS, var3
c=114;
NWBsessions(c).session='P44CS_090516';
NWBsessions(c).sessionID='P44CS';
NWBsessions(c).EXPERIMENTIDLearn=80;
NWBsessions(c).EXPERIMENTIDRecog=81;  
NWBsessions(c).taskDescr='NO';
NWBsessions(c).variant=3;
NWBsessions(c).blockIDLearn=1; 
NWBsessions(c).blockIDRecog=2;
NWBsessions(c).patient_nb=38;
NWBsessions(c).patientsession=1;
NWBsessions(c).diagnosisCode=1;

%NO P47CS, var3
c=115;
NWBsessions(c).session='P47CS_022017';
NWBsessions(c).sessionID='P47CS';
NWBsessions(c).EXPERIMENTIDLearn=80;
NWBsessions(c).EXPERIMENTIDRecog=81;  
NWBsessions(c).taskDescr='NO';
NWBsessions(c).variant=3;
NWBsessions(c).blockIDLearn=1; 
NWBsessions(c).blockIDRecog=2;
NWBsessions(c).patient_nb=39;
NWBsessions(c).patientsession=1;
NWBsessions(c).diagnosisCode=1;

%NO P48CS, var3
c=116;
NWBsessions(c).session='P48CS_031017';
NWBsessions(c).sessionID='P48CS';
NWBsessions(c).EXPERIMENTIDLearn=80;
NWBsessions(c).EXPERIMENTIDRecog=81;  
NWBsessions(c).taskDescr='NO';
NWBsessions(c).variant=3;
NWBsessions(c).blockIDLearn=1; 
NWBsessions(c).blockIDRecog=2;
NWBsessions(c).patient_nb=40;
NWBsessions(c).patientsession=1;
NWBsessions(c).diagnosisCode=2;

%NO P49CS, var3
c=117;
NWBsessions(c).session='P49CS_052217';
NWBsessions(c).sessionID='P49CS';
NWBsessions(c).EXPERIMENTIDLearn=80;
NWBsessions(c).EXPERIMENTIDRecog=81;  
NWBsessions(c).taskDescr='NO';
NWBsessions(c).variant=3;
NWBsessions(c).blockIDLearn=1; 
NWBsessions(c).blockIDRecog=2;
NWBsessions(c).patient_nb=41;
NWBsessions(c).patientsession=1;
NWBsessions(c).diagnosisCode=2;

%NO P49CS, var1
c=118;
NWBsessions(c).session='P49CS_052617';
NWBsessions(c).sessionID='P49CS';
NWBsessions(c).EXPERIMENTIDLearn=80;
NWBsessions(c).EXPERIMENTIDRecog=81;  
NWBsessions(c).taskDescr='NO';
NWBsessions(c).variant=1;
NWBsessions(c).blockIDLearn=1; 
NWBsessions(c).blockIDRecog=2;
NWBsessions(c).patient_nb=41;
NWBsessions(c).patientsession=2;
NWBsessions(c).diagnosisCode=2;

%NO P51CS, var3
c=119;
NWBsessions(c).session='P51CS_070117';
NWBsessions(c).sessionID='P51CS';
NWBsessions(c).EXPERIMENTIDLearn=80;
NWBsessions(c).EXPERIMENTIDRecog=81;  
NWBsessions(c).taskDescr='NO3';
NWBsessions(c).variant=3;
NWBsessions(c).blockIDLearn=1; 
NWBsessions(c).blockIDRecog=2;
NWBsessions(c).patient_nb=42;
NWBsessions(c).patientsession=1;
NWBsessions(c).diagnosisCode=0;

%NO P51CS, var1
c=120;
NWBsessions(c).session='P51CS_070117';
NWBsessions(c).sessionID='P51CS';
NWBsessions(c).EXPERIMENTIDLearn=80;
NWBsessions(c).EXPERIMENTIDRecog=81;  
NWBsessions(c).taskDescr='NO1';
NWBsessions(c).variant=1;
NWBsessions(c).blockIDLearn=1; 
NWBsessions(c).blockIDRecog=2;
NWBsessions(c).patient_nb=42;
NWBsessions(c).patientsession=2;
NWBsessions(c).diagnosisCode=0;

%=====
%
NWB_listOf_allUsable = [];
usable=[];
for k=1:length(NWBsessions)
    if ~isempty( NWBsessions(k).session )
        NWB_listOf_allUsable = [NWB_listOf_allUsable k];
    end
end
