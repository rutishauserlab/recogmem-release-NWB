%% Convert INI file into NOsessions 


function [NOsessions] = convertIni2NOsessions(keys) 


nosessions.session = {};
nosessions.sessionID = {};
nosessions.EXPERIMENTIDLearn  = {};
nosessions.EXPERIMENTIDRecog = {};
nosessions.taskDescr = {};
nosessions.variant = {};
nosessions.blockIDLearn = {};
nosessions.blockIDRecog = {};
nosessions.patient_nb = {};
nosessions.patientsession = {};
nosessions.diagnosisCode = {};
nosessions.phaseShiftCorrection = {};
nosessions.ID = {};
nosessions.age = {};
nosessions.sex = {};
nosessions.date = {}; 
nosessions.filename = {}; 
nosessions.LA = {}; 
nosessions.RA = {};
nosessions.LH = {}; 
nosessions.RH = {};


for i =1:length(keys)
    
    % == Assign the sessions 
    if strcmpi(keys(i, 3), 'nosessions.session')
        session = cell2mat(keys(i, 4));
        %Remove substring 
        session = erase(session, '''');
        
        nosessions(str2num(cell2mat(keys(i, 1)))).session = session;
    end 
    
    % == Assign session IDs
    if strcmpi(keys(i, 3), 'nosessions.sessionID')
        sessionID = cell2mat(keys(i, 4));
        %Remove extra whitespace 
        sessionID = strtrim(sessionID);
        %Remove Substring 
        sessionID = erase(sessionID, '''');
        
        %Remove comments in INI 
        if contains(sessionID, '#')
            removeExpID = strfind(sessionID, '#');
            sessionID(removeExpID:end) = [];
            sessionID = strtrim(sessionID);
            sessionID = erase(sessionID, '''');
        end 
        
        nosessions(str2num(cell2mat(keys(i, 1)))).sessionID = sessionID;
        
    end 
    
    % == Assign ExperimentIDLearn 
    if strcmpi(keys(i, 3), 'nosessions.experimentidlearn')
        ExperimentIDLearn = cell2mat(keys(i, 4));
        %Remove extra whitespace 
        ExperimentIDLearn = strtrim(ExperimentIDLearn);
        %Remove Substring 
        ExperimentIDLearn = erase(ExperimentIDLearn, '''');
        
        %Remove comments in INI 
        if contains(ExperimentIDLearn, '#');
            removeExpID = strfind(ExperimentIDLearn, '#');
            ExperimentIDLearn(removeExpID:end) = [];
            ExperimentIDLearn = strtrim(ExperimentIDLearn);
            ExperimentIDLearn = erase(ExperimentIDLearn, '''');
        end 
        
        nosessions(str2num(cell2mat(keys(i, 1)))).EXPERIMENTIDLearn = str2num(ExperimentIDLearn);
        
    end 
    
    % == Assign ExperimentIDRecog
    if strcmpi(keys(i, 3), 'nosessions.experimentidrecog')
        ExperimentIDRecog = cell2mat(keys(i, 4));
        ExperimentIDRecog = erase(ExperimentIDRecog, '''');
            
        %Remove comments in INI 
        if contains(ExperimentIDRecog, '#');
            removeExpID = strfind(ExperimentIDRecog, '#');
            ExperimentIDRecog(removeExpID:end) = [];
            ExperimentIDRecog = strtrim(ExperimentIDRecog);
            ExperimentIDRecog = erase(ExperimentIDRecog, '''');
        end 
        
        nosessions(str2num(cell2mat(keys(i, 1)))).EXPERIMENTIDRecog = str2num(ExperimentIDRecog);
        
    end 
    
    % == Assign taskDescr
    if strcmpi(keys(i, 3), 'nosessions.taskDescr')
        taskDescr = cell2mat(keys(i, 4));
        taskDescr = erase(taskDescr, '''');
            
        %Remove comments in INI 
        if contains(taskDescr, '#')
            removeExpID = strfind(taskDescr, '#');
            taskDescr(removeExpID:end) = [];
            taskDescr = strtrim(taskDescr);
            taskDescr = erase(taskDescr, '''');
        end 
        
        nosessions(str2num(cell2mat(keys(i, 1)))).taskDescr = taskDescr;
        
    end
    
    % == Assign variant
    if strcmpi(keys(i, 3), 'nosessions.variant')
        variant = cell2mat(keys(i, 4));
        variant = erase(variant, '''');
            
        %Remove comments in INI 
        if contains(variant, '#')
            removeExpID = strfind(variant, '#');
            variant(removeExpID:end) = [];
            variant = strtrim(variant);
            variant = erase(variant, '''');
        end 
        
        nosessions(str2num(cell2mat(keys(i, 1)))).variant = str2num(variant);
        
    end
    
    % == Assign blockIDLearn
    if strcmpi(keys(i, 3), 'nosessions.blockIDLearn')
        blockIDLearn = cell2mat(keys(i, 4));
        blockIDLearn = erase(blockIDLearn, '''');
        
        %Remove comments in INI 
        if contains(blockIDLearn, '#')
            removeExpID = strfind(blockIDLearn, '#');
            blockIDLearn(removeExpID:end) = [];
            blockIDLearn = strtrim(blockIDLearn);
            blockIDLearn = erase(blockIDLearn, '''');
        end 
        
        nosessions(str2num(cell2mat(keys(i, 1)))).blockIDLearn = str2num(blockIDLearn);
        
    end
    
    % == Assign blockIDRecog
    if strcmpi(keys(i, 3), 'nosessions.blockIDRecog')
        blockIDRecog = cell2mat(keys(i, 4));
        blockIDRecog = erase(blockIDRecog, '''');
        
        %Remove comments in INI 
        if contains(blockIDRecog, '#')
            removeExpID = strfind(blockIDRecog, '#');
            blockIDRecog(removeExpID:end) = [];
            blockIDRecog = strtrim(blockIDRecog);
            blockIDRecog = erase(blockIDRecog, '''');
        end 
        
        nosessions(str2num(cell2mat(keys(i, 1)))).blockIDRecog = str2num(blockIDRecog);
        
    end
    
    % == Assign patient_nb
    if strcmpi(keys(i, 3), 'nosessions.patient_nb')
        patient_nb = cell2mat(keys(i, 4));
        patient_nb = erase(patient_nb, '''');
        
        %Remove comments in INI 
        if contains(patient_nb, '#')
            removeExpID = strfind(patient_nb, '#');
            patient_nb(removeExpID:end) = [];
            patient_nb = strtrim(patient_nb);
            patient_nb = erase(patient_nb, '''');
        end 
        
        nosessions(str2num(cell2mat(keys(i, 1)))).patient_nb = str2num(patient_nb);
        
    end
    
    % == Assign patientsession
    if strcmpi(keys(i, 3), 'nosessions.patientsession')
        patientsession = cell2mat(keys(i, 4));
        patientsession = erase(patientsession, '''');
        
        %Remove comments in INI 
        if contains(patientsession, '#')
            removeExpID = strfind(patientsession, '#');
            patientsession(removeExpID:end) = [];
            patientsession = strtrim(patientsession);
            patientsession = erase(patientsession, '''');
        end 
        
        nosessions(str2num(cell2mat(keys(i, 1)))).patientsession = str2num(patientsession);
        
    end
    
    % == Assign diagnosisCode
    if strcmpi(keys(i, 3), 'nosessions.diagnosisCode')
        diagnosisCode = cell2mat(keys(i, 4));
        diagnosisCode = erase(diagnosisCode, '''');
        
        %Remove comments in INI 
        if contains(diagnosisCode, '#')
            removeExpID = strfind(diagnosisCode, '#');
            diagnosisCode(removeExpID:end) = [];
            diagnosisCode = strtrim(diagnosisCode);
            diagnosisCode = erase(diagnosisCode, '''');
        end 
        
        nosessions(str2num(cell2mat(keys(i, 1)))).diagnosisCode = str2num(diagnosisCode);
        
    end
    
    % == Assign phaseShiftCorrection
    if strcmpi(keys(i, 3), 'nosessions.phaseshiftcorrection')
        phaseshiftcorrection = cell2mat(keys(i, 4));
        phaseshiftcorrection = erase(phaseshiftcorrection, '''');
        
        %Remove comments in INI 
        if contains(phaseshiftcorrection, '#')
            removeExpID = strfind(phaseshiftcorrection, '#');
            phaseshiftcorrection(removeExpID:end) = [];
            phaseshiftcorrection = strtrim(phaseshiftcorrection);
            phaseshiftcorrection = erase(phaseshiftcorrection, '''');
        end 
        
        nosessions(str2num(cell2mat(keys(i, 1)))).phaseShiftCorrection = str2num(phaseshiftcorrection);
        
    end
    
    % == Assign session ID
    if strcmpi(keys(i, 3), 'nosessions.id')
        id = cell2mat(keys(i, 4));
        id = erase(id, '''');
        
        %Remove comments in INI 
        if contains(id, '#')
            removeExpID = strfind(id, '#');
            id(removeExpID:end) = [];
            id = strtrim(id);
            id = erase(id, '''');
        end 
        
        nosessions(str2num(cell2mat(keys(i, 1)))).ID = id;
        
    end
    
    % == Assign age 
    if strcmpi(keys(i, 3), 'nosessions.age')
        age = cell2mat(keys(i, 4));
        age = erase(age, '''');
        
        %Remove comments in INI 
        if contains(age, '#')
            removeExpID = strfind(age, '#');
            age(removeExpID:end) = [];
            age = strtrim(age);
            age = erase(age, '''');
        end 
        
        nosessions(str2num(cell2mat(keys(i, 1)))).age = str2num(age);
        
    end
    
    % == Assign sex 
    if strcmpi(keys(i, 3), 'nosessions.sex')
        sex = cell2mat(keys(i, 4));
        sex = erase(sex, '''');
        
        %Remove comments in INI 
        if contains(sex, '#')
            removeExpID = strfind(sex, '#');
            sex(removeExpID:end) = [];
            sex = strtrim(sex);
            sex = erase(sex, '''');
        end 
        
        nosessions(str2num(cell2mat(keys(i, 1)))).sex = sex;
        
    end
    
    % == Assign Date
    if strcmpi(keys(i, 3), 'nosessions.date')
        date = cell2mat(keys(i, 4));
        date = erase(date, '''');
        
        %Remove comments in INI 
        if contains(date, '#')
            removeExpID = strfind(date, '#');
            date(removeExpID:end) = [];
            date = strtrim(date);
            date = erase(date, '''');
        end 
        
        nosessions(str2num(cell2mat(keys(i, 1)))).date = date;
        
    end
    
    % == Add NWB file 
    if strcmpi(keys(i, 3), 'nosessions.filename')
        filename = cell2mat(keys(i, 4));
        filename = erase(filename, '''');
        
        %Remove comments in INI 
        if contains(filename, '#')
            removeExpID = strfind(filename, '#');
            filename(removeExpID:end) = [];
            filename = strtrim(filename);
            filename = erase(filename, '''');
        end 
        nosessions(str2num(cell2mat(keys(i, 1)))).filename = filename;
    end
   
   
    % == Add LA (Left Amygdala MNI coordinates) 
    if strcmpi(keys(i, 3), 'nosessions.la')
        LA = cell2mat(keys(i, 4));
        LA = erase(LA, '''');
        
        %Remove comments in INI 
        if contains(LA, '#')
            removeExpID = strfind(LA, '#');
            LA(removeExpID:end) = [];
            LA = strtrim(LA);
            LA = erase(LA, '''');
        end 
        nosessions(str2num(cell2mat(keys(i, 1)))).LA = LA;
    end
    
    
     % == Add RA (Right Amygdala MNI coordinates) 
    if strcmpi(keys(i, 3), 'nosessions.ra')
        RA = cell2mat(keys(i, 4));
        RA = erase(RA, '''');
        
        %Remove comments in INI 
        if contains(RA, '#')
            removeExpID = strfind(RA, '#');
            RA(removeExpID:end) = [];
            RA = strtrim(RA);
            RA = erase(RA, '''');
        end 
        nosessions(str2num(cell2mat(keys(i, 1)))).RA = RA;
    end
    
    % == Add LH (Left Hippocampus MNI coordinates) 
    if strcmpi(keys(i, 3), 'nosessions.lh')
        LH = cell2mat(keys(i, 4));
        LH = erase(LH, '''');
        
        %Remove comments in INI 
        if contains(LH, '#')
            removeExpID = strfind(LH, '#');
            LH(removeExpID:end) = [];
            LH = strtrim(LH);
            LH = erase(LH, '''');
        end 
        nosessions(str2num(cell2mat(keys(i, 1)))).LH = LH;
    end
    
    % == Add RH (Right Hippocampus MNI coordinates) 
    if strcmpi(keys(i, 3), 'nosessions.rh')
        RH = cell2mat(keys(i, 4));
        RH = erase(RH, '''');
        
        %Remove comments in INI 
        if contains(RH, '#')
            removeExpID = strfind(RH, '#');
            RH(removeExpID:end) = [];
            RH = strtrim(RH);
            RH = erase(RH, '''');
        end 
        nosessions(str2num(cell2mat(keys(i, 1)))).RH = RH;
    end
    
    
end 

NOsessions = nosessions; 

