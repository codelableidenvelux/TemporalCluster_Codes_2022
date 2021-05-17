function [outpsyid] = qaid2psyid(qaid)

demoinfo = readtable('/media/Storage/AgestudyNL/Psytoolkit/DemoInfo/session_info.csv', 'Delimiter', ',');

user_id = demoinfo(strcmp(demoinfo.participation_id, qaid), :).user_id;

outpsyid = generate_id(user_id);