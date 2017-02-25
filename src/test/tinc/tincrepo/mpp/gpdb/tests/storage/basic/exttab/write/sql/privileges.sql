--
-- test CREATE EXTERNAL TABLE privileges
--
--
-- Super User priv
--
CREATE ROLE ext_su SUPERUSER; -- SU with no privs in pg_auth
select rolname, rolcreaterextgpfd,rolcreaterexthttp,rolcreatewextgpfd from pg_authid where rolname='ext_su';
--
SET SESSION AUTHORIZATION ext_su;
create readable external table priv_ext_test1(a int) location ('gpfdist://@hostname@:@gp_port@/file') format 'text';
select * from priv_ext_test1 order by a;
create writable external table priv_ext_test2(a int) location ('gpfdist://@hostname@:@gp_port@/output/wet_file') format 'text';
insert into priv_ext_test2 values (generate_series(1,10));
create readable external web table priv_ext_test3(a int) location ('http://@hostname@:@gp_port@/file') format 'text';
select * from priv_ext_test3 order by a;

drop external table priv_ext_test1;
drop external table priv_ext_test2;
drop external table priv_ext_test3;
RESET SESSION AUTHORIZATION;

--
-- Role to create RET gpfdist 
--
CREATE ROLE ext_u1 CREATEEXTTABLE(protocol='gpfdist', type='readable');
select rolname, rolcreaterextgpfd,rolcreaterexthttp,rolcreatewextgpfd from pg_authid where rolname='ext_u1';
--
SET SESSION AUTHORIZATION ext_u1;
create readable external table priv_ext_test1(a int) location ('gpfdist://@hostname@:@gp_port@/file') format 'text';
select * from priv_ext_test1 order by a;
create writable external table priv_ext_test2(a int) location ('gpfdist://@hostname@:@gp_port@/output/wet_file') format 'text'; -- fail
create readable external web table priv_ext_test3(a int) location ('http://@hostname@:@gp_port@/file') format 'text'; -- fail

drop external table priv_ext_test1;
RESET SESSION AUTHORIZATION;

--
-- Role to create WET gpfdist
--
CREATE ROLE ext_u2 CREATEEXTTABLE(protocol='gpfdist', type='writable');
select rolname, rolcreaterextgpfd,rolcreaterexthttp,rolcreatewextgpfd from pg_authid where rolname='ext_u2';
--
SET SESSION AUTHORIZATION ext_u2;
create readable external table priv_ext_test1(a int) location ('gpfdist://@hostname@:@gp_port@/file') format 'text';  -- fail
create writable external table priv_ext_test2(a int) location ('gpfdist://@hostname@:@gp_port@/output/wet_file') format 'text';
insert into priv_ext_test2 values (generate_series(1,10));
create readable external web table priv_ext_test3(a int) location ('http://@hostname@:@gp_port@/file') format 'text'; -- fail

drop external table priv_ext_test2;
RESET SESSION AUTHORIZATION;

--
-- Role to create RET http
--
CREATE ROLE ext_u3 CREATEEXTTABLE(protocol='http', type='readable');
select rolname, rolcreaterextgpfd,rolcreaterexthttp,rolcreatewextgpfd from pg_authid where rolname='ext_u3';
--
SET SESSION AUTHORIZATION ext_u3;
create readable external table priv_ext_test1(a int) location ('gpfdist://@hostname@:@gp_port@/file') format 'text';  -- fail
create writable external table priv_ext_test2(a int) location ('gpfdist://@hostname@:@gp_port@/file') format 'text';  -- fail
create readable external web table priv_ext_test3(a int) location ('http://@hostname@:@gp_port@/file') format 'text';
select * from priv_ext_test3 order by a;


drop external table priv_ext_test3;
RESET SESSION AUTHORIZATION;

--
-- Role to create RET http and NO create RET http
--
CREATE ROLE ext_u5 CREATEEXTTABLE(protocol='http') NOCREATEEXTTABLE(protocol='http', type='readable'); -- fail due to conflict
select rolname, rolcreaterextgpfd,rolcreaterexthttp,rolcreatewextgpfd from pg_authid where rolname='ext_u5';
--
-- 
--
CREATE ROLE ext_u12 CREATEEXTTABLE(protocol='http',type='readable') NOCREATEEXTTABLE(protocol='http', type='readable'); -- fail due to conflict
select rolname, rolcreaterextgpfd,rolcreaterexthttp,rolcreatewextgpfd from pg_authid where rolname='ext_u12';


--
-- Role to create RET gpfdist and NO create RET gpfdist
--

CREATE ROLE ext_u4 CREATEEXTTABLE(protocol='gpfdist') NOCREATEEXTTABLE(protocol='gpfdist', type='readable'); -- fail due to conflict
select rolname, rolcreaterextgpfd,rolcreaterexthttp,rolcreatewextgpfd from pg_authid where rolname='ext_u4';

CREATE ROLE ext_u7 CREATEEXTTABLE(type='readable') NOCREATEEXTTABLE(protocol='gpfdist', type='readable'); -- fail due to conflict
select rolname, rolcreaterextgpfd,rolcreaterexthttp,rolcreatewextgpfd from pg_authid where rolname='ext_u7';

CREATE ROLE ext_u10 CREATEEXTTABLE(protocol='gpfdist',type='readable') NOCREATEEXTTABLE(protocol='gpfdist', type='readable'); -- fail due to conflict
select rolname, rolcreaterextgpfd,rolcreaterexthttp,rolcreatewextgpfd from pg_authid where rolname='ext_u10';


--
-- Role to create WET gpfdist and NO create WET gpfdist
--
CREATE ROLE ext_u9 CREATEEXTTABLE(type='writable') NOCREATEEXTTABLE(protocol='gpfdist', type='writable'); -- fail due to conflict
select rolname, rolcreaterextgpfd,rolcreaterexthttp,rolcreatewextgpfd from pg_authid where rolname='ext_u9';
--
-- 
--
CREATE ROLE ext_u11 CREATEEXTTABLE(protocol='gpfdist',type='writable') NOCREATEEXTTABLE(protocol='gpfdist', type='writable'); -- fail due to conflict
select rolname, rolcreaterextgpfd,rolcreaterexthttp,rolcreatewextgpfd from pg_authid where rolname='ext_u11';
--
-- Role to create RET gpfdist and NO create WET gpfdist
--
CREATE ROLE ext_u6 CREATEEXTTABLE(protocol='gpfdist') NOCREATEEXTTABLE(protocol='gpfdist', type='writable'); 
select rolname, rolcreaterextgpfd,rolcreaterexthttp,rolcreatewextgpfd from pg_authid where rolname='ext_u6';
--
SET SESSION AUTHORIZATION ext_u6;
create readable external table priv_ext_test1(a int) location ('gpfdist://@hostname@:@gp_port@/file') format 'text';
select * from priv_ext_test1 order by a;
create writable external table priv_ext_test2(a int) location ('gpfdist://@hostname@:@gp_port@/file') format 'text'; -- fail
create readable external web table priv_ext_test3(a int) location ('http://@hostname@:@gp_port@/file') format 'text'; -- fail

drop external table priv_ext_test1;
RESET SESSION AUTHORIZATION;
--
-- 
--
CREATE ROLE ext_u13 CREATEEXTTABLE(protocol='gpfdist',type='readable') NOCREATEEXTTABLE(protocol='gpfdist', type='writable'); 
select rolname, rolcreaterextgpfd,rolcreaterexthttp,rolcreatewextgpfd from pg_authid where rolname='ext_u13';
--
SET SESSION AUTHORIZATION ext_u13;
create readable external table priv_ext_test1(a int) location ('gpfdist://@hostname@:@gp_port@/file') format 'text';
select * from priv_ext_test1 order by a;
create writable external table priv_ext_test2(a int) location ('gpfdist://@hostname@:@gp_port@/file') format 'text'; -- fail
create readable external web table priv_ext_test3(a int) location ('http://@hostname@:@gp_port@/file') format 'text'; -- fail

drop external table priv_ext_test1;
RESET SESSION AUTHORIZATION;

--
-- Role to create RET gpfdist and NO create RET http
--
CREATE ROLE ext_u8 CREATEEXTTABLE(type='readable') NOCREATEEXTTABLE(protocol='http', type='readable'); 
select rolname, rolcreaterextgpfd,rolcreaterexthttp,rolcreatewextgpfd from pg_authid where rolname='ext_u8';
--
SET SESSION AUTHORIZATION ext_u8;
create readable external table priv_ext_test1(a int) location ('gpfdist://@hostname@:@gp_port@/file') format 'text';
select * from priv_ext_test1 order by a;
create writable external table priv_ext_test2(a int) location ('gpfdist://@hostname@:@gp_port@/file') format 'text'; -- fail
create readable external web table priv_ext_test3(a int) location ('http://@hostname@:@gp_port@/file') format 'text'; -- fail

drop external table priv_ext_test1;
RESET SESSION AUTHORIZATION;
--
-- 
--
CREATE ROLE ext_u14 CREATEEXTTABLE(protocol='gpfdist',type='readable') NOCREATEEXTTABLE(protocol='http', type='readable'); 
select rolname, rolcreaterextgpfd,rolcreaterexthttp,rolcreatewextgpfd from pg_authid where rolname='ext_u14';
--
SET SESSION AUTHORIZATION ext_u14;
create readable external table priv_ext_test1(a int) location ('gpfdist://@hostname@:@gp_port@/file') format 'text';
select * from priv_ext_test1 order by a;
create writable external table priv_ext_test2(a int) location ('gpfdist://@hostname@:@gp_port@/file') format 'text'; -- fail
create readable external web table priv_ext_test3(a int) location ('http://@hostname@:@gp_port@/file') format 'text'; -- fail

drop external table priv_ext_test1;
RESET SESSION AUTHORIZATION;

--
-- Role to create WET gpfdist and NO create RET gpfdist
--
CREATE ROLE ext_u15 CREATEEXTTABLE(protocol='gpfdist',type='writable') NOCREATEEXTTABLE(protocol='gpfdist', type='readable');
select rolname, rolcreaterextgpfd,rolcreaterexthttp,rolcreatewextgpfd from pg_authid where rolname='ext_u15';
--
SET SESSION AUTHORIZATION ext_u15;
create readable external table priv_ext_test1(a int) location ('gpfdist://@hostname@:@gp_port@/file') format 'text';  -- fail
create writable external table priv_ext_test2(a int) location ('gpfdist://@hostname@:@gp_port@/output/wet_file') format 'text';
insert into priv_ext_test2 values (generate_series(1,10));
create readable external web table priv_ext_test3(a int) location ('http://@hostname@:@gp_port@/file') format 'text'; -- fail

drop external table priv_ext_test2;
RESET SESSION AUTHORIZATION;


--
-- Role to create WET gpfdist and NO create RET http
--
CREATE ROLE ext_u16 CREATEEXTTABLE(protocol='gpfdist',type='writable') NOCREATEEXTTABLE(protocol='http', type='readable'); 
select rolname, rolcreaterextgpfd,rolcreaterexthttp,rolcreatewextgpfd from pg_authid where rolname='ext_u16';
--
SET SESSION AUTHORIZATION ext_u16;
create readable external table priv_ext_test1(a int) location ('gpfdist://@hostname@:@gp_port@/file') format 'text';  -- fail
create writable external table priv_ext_test2(a int) location ('gpfdist://@hostname@:@gp_port@/output/wet_file') format 'text';
insert into priv_ext_test2 values (generate_series(1,10));
create readable external web table priv_ext_test3(a int) location ('http://@hostname@:@gp_port@/file') format 'text'; -- fail

drop external table priv_ext_test2;
RESET SESSION AUTHORIZATION;



--
-- Role to create RET http and NO create RET gpfdist
--
CREATE ROLE ext_u17 CREATEEXTTABLE(protocol='http',type='readable') NOCREATEEXTTABLE(protocol='gpfdist', type='readable');
select rolname, rolcreaterextgpfd,rolcreaterexthttp,rolcreatewextgpfd from pg_authid where rolname='ext_u17';
--
SET SESSION AUTHORIZATION ext_u17;
create readable external table priv_ext_test1(a int) location ('gpfdist://@hostname@:@gp_port@/file') format 'text';  -- fail
create writable external table priv_ext_test2(a int) location ('gpfdist://@hostname@:@gp_port@/file') format 'text';  -- fail
create readable external web table priv_ext_test3(a int) location ('http://@hostname@:@gp_port@/file') format 'text';
select * from priv_ext_test3 order by a;


drop external table priv_ext_test3;
RESET SESSION AUTHORIZATION;



--
-- Role to create RET http and NO create WET gpfdist
--
CREATE ROLE ext_u18 CREATEEXTTABLE(protocol='http',type='readable') NOCREATEEXTTABLE(protocol='gpfdist', type='writable'); 
select rolname, rolcreaterextgpfd,rolcreaterexthttp,rolcreatewextgpfd from pg_authid where rolname='ext_u18';
--
SET SESSION AUTHORIZATION ext_u18;
create readable external table priv_ext_test1(a int) location ('gpfdist://@hostname@:@gp_port@/file') format 'text';  -- fail
create writable external table priv_ext_test2(a int) location ('gpfdist://@hostname@:@gp_port@/file') format 'text';  -- fail
create readable external web table priv_ext_test3(a int) location ('http://@hostname@:@gp_port@/file') format 'text';
select * from priv_ext_test3 order by a;


drop external table priv_ext_test3;
RESET SESSION AUTHORIZATION;

--
-- Role to create RET gpfdist and create RET gpfdist
--
CREATE ROLE ext_u19 CREATEEXTTABLE(protocol='gpfdist') CREATEEXTTABLE(protocol='gpfdist', type='readable'); 
select rolname, rolcreaterextgpfd,rolcreaterexthttp,rolcreatewextgpfd from pg_authid where rolname='ext_u19';
--
SET SESSION AUTHORIZATION ext_u19;
create readable external table priv_ext_test1(a int) location ('gpfdist://@hostname@:@gp_port@/file') format 'text';
select * from priv_ext_test1 order by a;
create writable external table priv_ext_test2(a int) location ('gpfdist://@hostname@:@gp_port@/file') format 'text'; -- fail
create readable external web table priv_ext_test3(a int) location ('http://@hostname@:@gp_port@/file') format 'text'; -- fail

drop external table priv_ext_test1;
RESET SESSION AUTHORIZATION;
--
--
--
CREATE ROLE ext_u22 CREATEEXTTABLE(type='readable') CREATEEXTTABLE(protocol='gpfdist', type='readable'); 
select rolname, rolcreaterextgpfd,rolcreaterexthttp,rolcreatewextgpfd from pg_authid where rolname='ext_u22';
--
SET SESSION AUTHORIZATION ext_u22;
create readable external table priv_ext_test1(a int) location ('gpfdist://@hostname@:@gp_port@/file') format 'text';
select * from priv_ext_test1 order by a;
create writable external table priv_ext_test2(a int) location ('gpfdist://@hostname@:@gp_port@/file') format 'text'; -- fail
create readable external web table priv_ext_test3(a int) location ('http://@hostname@:@gp_port@/file') format 'text'; -- fail

drop external table priv_ext_test1;
RESET SESSION AUTHORIZATION;
--
-- 
--
CREATE ROLE ext_u25 CREATEEXTTABLE(protocol='gpfdist',type='readable') CREATEEXTTABLE(protocol='gpfdist', type='readable'); 
select rolname, rolcreaterextgpfd,rolcreaterexthttp,rolcreatewextgpfd from pg_authid where rolname='ext_u25';
--
SET SESSION AUTHORIZATION ext_u25;
create readable external table priv_ext_test1(a int) location ('gpfdist://@hostname@:@gp_port@/file') format 'text';
select * from priv_ext_test1 order by a;
create writable external table priv_ext_test2(a int) location ('gpfdist://@hostname@:@gp_port@/file') format 'text'; -- fail
create readable external web table priv_ext_test3(a int) location ('http://@hostname@:@gp_port@/file') format 'text'; -- fail

drop external table priv_ext_test1;
RESET SESSION AUTHORIZATION;

--
-- Role to create RET http and  create RET http
--
CREATE ROLE ext_u20 CREATEEXTTABLE(protocol='http') CREATEEXTTABLE(protocol='http', type='readable'); 
select rolname, rolcreaterextgpfd,rolcreaterexthttp,rolcreatewextgpfd from pg_authid where rolname='ext_u20';
--
SET SESSION AUTHORIZATION ext_u20;
create readable external table priv_ext_test1(a int) location ('gpfdist://@hostname@:@gp_port@/file') format 'text';  -- fail
create writable external table priv_ext_test2(a int) location ('gpfdist://@hostname@:@gp_port@/file') format 'text';  -- fail
create readable external web table priv_ext_test3(a int) location ('http://@hostname@:@gp_port@/file') format 'text';
select * from priv_ext_test3 order by a;

drop external table priv_ext_test3;
RESET SESSION AUTHORIZATION;

--
-- 
--
CREATE ROLE ext_u27 CREATEEXTTABLE(protocol='http',type='readable') CREATEEXTTABLE(protocol='http', type='readable'); 
select rolname, rolcreaterextgpfd,rolcreaterexthttp,rolcreatewextgpfd from pg_authid where rolname='ext_u27';
--
SET SESSION AUTHORIZATION ext_u27;
create readable external table priv_ext_test1(a int) location ('gpfdist://@hostname@:@gp_port@/file') format 'text';  -- fail
create writable external table priv_ext_test2(a int) location ('gpfdist://@hostname@:@gp_port@/file') format 'text';  -- fail
create readable external web table priv_ext_test3(a int) location ('http://@hostname@:@gp_port@/file') format 'text';
select * from priv_ext_test3 order by a;

drop external table priv_ext_test3;
RESET SESSION AUTHORIZATION;

--
-- Role to create RET gpfdist and create WET gpfdist
--
CREATE ROLE ext_u21 CREATEEXTTABLE(protocol='gpfdist') CREATEEXTTABLE(protocol='gpfdist', type='writable'); 
select rolname, rolcreaterextgpfd,rolcreaterexthttp,rolcreatewextgpfd from pg_authid where rolname='ext_u21';
--
SET SESSION AUTHORIZATION ext_u21;
create readable external table priv_ext_test1(a int) location ('gpfdist://@hostname@:@gp_port@/file') format 'text';
select * from priv_ext_test1 order by a;
create writable external table priv_ext_test2(a int) location ('gpfdist://@hostname@:@gp_port@/output/wet_file') format 'text'; 
insert into priv_ext_test2 values (generate_series(1,10));
create readable external web table priv_ext_test3(a int) location ('http://@hostname@:@gp_port@/file') format 'text'; -- fail

drop external table priv_ext_test1;
drop external table priv_ext_test2;
RESET SESSION AUTHORIZATION;
--
--
--
CREATE ROLE ext_u28 CREATEEXTTABLE(protocol='gpfdist',type='readable') CREATEEXTTABLE(protocol='gpfdist', type='writable'); 
select rolname, rolcreaterextgpfd,rolcreaterexthttp,rolcreatewextgpfd from pg_authid where rolname='ext_u28';
--
SET SESSION AUTHORIZATION ext_u28;
create readable external table priv_ext_test1(a int) location ('gpfdist://@hostname@:@gp_port@/file') format 'text';
select * from priv_ext_test1 order by a;
create writable external table priv_ext_test2(a int) location ('gpfdist://@hostname@:@gp_port@/output/wet_file') format 'text'; 
insert into priv_ext_test2 values (generate_series(1,10));
create readable external web table priv_ext_test3(a int) location ('http://@hostname@:@gp_port@/file') format 'text'; -- fail

drop external table priv_ext_test1;
drop external table priv_ext_test2;
RESET SESSION AUTHORIZATION;

--
-- 
--
CREATE ROLE ext_u30 CREATEEXTTABLE(protocol='gpfdist',type='writable') CREATEEXTTABLE(protocol='gpfdist', type='readable');
select rolname, rolcreaterextgpfd,rolcreaterexthttp,rolcreatewextgpfd from pg_authid where rolname='ext_u30';
--
SET SESSION AUTHORIZATION ext_u30;
create readable external table priv_ext_test1(a int) location ('gpfdist://@hostname@:@gp_port@/file') format 'text';
select * from priv_ext_test1 order by a;
create writable external table priv_ext_test2(a int) location ('gpfdist://@hostname@:@gp_port@/output/wet_file') format 'text'; 
insert into priv_ext_test2 values (generate_series(1,10));
create readable external web table priv_ext_test3(a int) location ('http://@hostname@:@gp_port@/file') format 'text'; -- fail

drop external table priv_ext_test1;
drop external table priv_ext_test2;
RESET SESSION AUTHORIZATION;

--
-- Role to create RET gpfdist and create RET http
--
CREATE ROLE ext_u23 CREATEEXTTABLE(type='readable') CREATEEXTTABLE(protocol='http', type='readable'); 
select rolname, rolcreaterextgpfd,rolcreaterexthttp,rolcreatewextgpfd from pg_authid where rolname='ext_u23';
--
SET SESSION AUTHORIZATION ext_u23;
create readable external table priv_ext_test1(a int) location ('gpfdist://@hostname@:@gp_port@/file') format 'text';
select * from priv_ext_test1 order by a;
create writable external table priv_ext_test2(a int) location ('gpfdist://@hostname@:@gp_port@/file') format 'text'; -- fail
create readable external web table priv_ext_test3(a int) location ('http://@hostname@:@gp_port@/file') format 'text';
select * from priv_ext_test3 order by a;

drop external table priv_ext_test1;
drop external table priv_ext_test3;
RESET SESSION AUTHORIZATION;

--
-- Role to create RET gpfdist and create RET http
--
CREATE ROLE ext_u29 CREATEEXTTABLE(protocol='gpfdist',type='readable') CREATEEXTTABLE(protocol='http', type='readable'); 
select rolname, rolcreaterextgpfd,rolcreaterexthttp,rolcreatewextgpfd from pg_authid where rolname='ext_u29';
--
SET SESSION AUTHORIZATION ext_u29;
create readable external table priv_ext_test1(a int) location ('gpfdist://@hostname@:@gp_port@/file') format 'text';
select * from priv_ext_test1 order by a;
create writable external table priv_ext_test2(a int) location ('gpfdist://@hostname@:@gp_port@/file') format 'text'; -- fail
create readable external web table priv_ext_test3(a int) location ('http://@hostname@:@gp_port@/file') format 'text';
select * from priv_ext_test3 order by a;

drop external table priv_ext_test1;
drop external table priv_ext_test3;
RESET SESSION AUTHORIZATION;
--
-- 
--
CREATE ROLE ext_u32 CREATEEXTTABLE(protocol='http',type='readable') CREATEEXTTABLE(protocol='gpfdist', type='readable');
select rolname, rolcreaterextgpfd,rolcreaterexthttp,rolcreatewextgpfd from pg_authid where rolname='ext_u32';
--
SET SESSION AUTHORIZATION ext_u32;
create readable external table priv_ext_test1(a int) location ('gpfdist://@hostname@:@gp_port@/file') format 'text';
select * from priv_ext_test1 order by a;
create writable external table priv_ext_test2(a int) location ('gpfdist://@hostname@:@gp_port@/file') format 'text'; -- fail
create readable external web table priv_ext_test3(a int) location ('http://@hostname@:@gp_port@/file') format 'text'; 
select * from priv_ext_test3 order by a;

drop external table priv_ext_test1;
drop external table priv_ext_test3;
RESET SESSION AUTHORIZATION;

--
-- Role to create WET gpfdist and create WET gpfdist
--
CREATE ROLE ext_u24 CREATEEXTTABLE(type='writable') CREATEEXTTABLE(protocol='gpfdist', type='writable'); 
select rolname, rolcreaterextgpfd,rolcreaterexthttp,rolcreatewextgpfd from pg_authid where rolname='ext_u24';
--
SET SESSION AUTHORIZATION ext_u24;
create readable external table priv_ext_test1(a int) location ('gpfdist://@hostname@:@gp_port@/file') format 'text';  -- fail
create writable external table priv_ext_test2(a int) location ('gpfdist://@hostname@:@gp_port@/output/wet_file') format 'text';
insert into priv_ext_test2 values (generate_series(1,10));
create readable external web table priv_ext_test3(a int) location ('http://@hostname@:@gp_port@/file') format 'text'; -- fail

drop external table priv_ext_test2;
RESET SESSION AUTHORIZATION;

--
-- 
--
CREATE ROLE ext_u26 CREATEEXTTABLE(protocol='gpfdist',type='writable') CREATEEXTTABLE(protocol='gpfdist', type='writable'); 
select rolname, rolcreaterextgpfd,rolcreaterexthttp,rolcreatewextgpfd from pg_authid where rolname='ext_u26';
--
SET SESSION AUTHORIZATION ext_u26;
create readable external table priv_ext_test1(a int) location ('gpfdist://@hostname@:@gp_port@/file') format 'text';  -- fail
create writable external table priv_ext_test2(a int) location ('gpfdist://@hostname@:@gp_port@/output/wet_file') format 'text';
insert into priv_ext_test2 values (generate_series(1,10));
create readable external web table priv_ext_test3(a int) location ('http://@hostname@:@gp_port@/file') format 'text'; -- fail

drop external table priv_ext_test2;
RESET SESSION AUTHORIZATION;


--
-- Role to create WET gpfdist and create RET http
--
CREATE ROLE ext_u31 CREATEEXTTABLE(protocol='gpfdist',type='writable') CREATEEXTTABLE(protocol='http', type='readable'); 
select rolname, rolcreaterextgpfd,rolcreaterexthttp,rolcreatewextgpfd from pg_authid where rolname='ext_u31';
--
SET SESSION AUTHORIZATION ext_u31;
create readable external table priv_ext_test1(a int) location ('gpfdist://@hostname@:@gp_port@/file') format 'text';  -- fail
create writable external table priv_ext_test2(a int) location ('gpfdist://@hostname@:@gp_port@/output/wet_file') format 'text';
insert into priv_ext_test2 values (generate_series(1,10));
create readable external web table priv_ext_test3(a int) location ('http://@hostname@:@gp_port@/file') format 'text'; 
select * from priv_ext_test3 order by a;

drop external table priv_ext_test2;
drop external table priv_ext_test3;
RESET SESSION AUTHORIZATION;

--
-- 
--
CREATE ROLE ext_u33 CREATEEXTTABLE(protocol='http',type='readable') CREATEEXTTABLE(protocol='gpfdist', type='writable'); 
select rolname, rolcreaterextgpfd,rolcreaterexthttp,rolcreatewextgpfd from pg_authid where rolname='ext_u33';
--
SET SESSION AUTHORIZATION ext_u33;
create readable external table priv_ext_test1(a int) location ('gpfdist://@hostname@:@gp_port@/file') format 'text';  -- fail
create writable external table priv_ext_test2(a int) location ('gpfdist://@hostname@:@gp_port@/output/wet_file') format 'text';
insert into priv_ext_test2 values (generate_series(1,10));
create readable external web table priv_ext_test3(a int) location ('http://@hostname@:@gp_port@/file') format 'text'; -- fail 

drop external table priv_ext_test2;
drop external table priv_ext_test3;
RESET SESSION AUTHORIZATION;



--
--
-- Role to NO create RET gpfdist and NO create RET gpfdist
--
CREATE ROLE ext_u34 NOCREATEEXTTABLE(protocol='gpfdist') NOCREATEEXTTABLE(protocol='gpfdist', type='readable'); 
select rolname, rolcreaterextgpfd,rolcreaterexthttp,rolcreatewextgpfd from pg_authid where rolname='ext_u34';
--
SET SESSION AUTHORIZATION ext_u34;
create readable external table priv_ext_test1(a int) location ('gpfdist://@hostname@:@gp_port@/file') format 'text';  --fail 
create writable external table priv_ext_test2(a int) location ('gpfdist://@hostname@:@gp_port@/file') format 'text'; --fail
create readable external web table priv_ext_test3(a int) location ('http://@hostname@:@gp_port@/file') format 'text';  --fail

drop external table priv_ext_test1;
drop external table priv_ext_test2;
drop external table priv_ext_test3;
RESET SESSION AUTHORIZATION;


--
CREATE ROLE ext_u40 NOCREATEEXTTABLE(protocol='gpfdist',type='readable') NOCREATEEXTTABLE(protocol='gpfdist', type='readable'); 
select rolname, rolcreaterextgpfd,rolcreaterexthttp,rolcreatewextgpfd from pg_authid where rolname='ext_u40';
--
SET SESSION AUTHORIZATION ext_u40;
create readable external table priv_ext_test1(a int) location ('gpfdist://@hostname@:@gp_port@/file') format 'text';  --fail 
create writable external table priv_ext_test2(a int) location ('gpfdist://@hostname@:@gp_port@/file') format 'text'; --fail
create readable external web table priv_ext_test3(a int) location ('http://@hostname@:@gp_port@/file') format 'text';  --fail

drop external table priv_ext_test1;
drop external table priv_ext_test2;
drop external table priv_ext_test3;
RESET SESSION AUTHORIZATION;
--
CREATE ROLE ext_u37 NOCREATEEXTTABLE(type='readable') NOCREATEEXTTABLE(protocol='gpfdist', type='readable'); 
select rolname, rolcreaterextgpfd,rolcreaterexthttp,rolcreatewextgpfd from pg_authid where rolname='ext_u37';
--
SET SESSION AUTHORIZATION ext_u37;
create readable external table priv_ext_test1(a int) location ('gpfdist://@hostname@:@gp_port@/file') format 'text';  --fail 
create writable external table priv_ext_test2(a int) location ('gpfdist://@hostname@:@gp_port@/file') format 'text';  --fail
create readable external web table priv_ext_test3(a int) location ('http://@hostname@:@gp_port@/file') format 'text';  --fail

drop external table priv_ext_test1;
drop external table priv_ext_test2;
drop external table priv_ext_test3;
RESET SESSION AUTHORIZATION;


--
-- Role to NO create RET http and NO create RET http
--
CREATE ROLE ext_u35 NOCREATEEXTTABLE(protocol='http') NOCREATEEXTTABLE(protocol='http', type='readable'); 
select rolname, rolcreaterextgpfd,rolcreaterexthttp,rolcreatewextgpfd from pg_authid where rolname='ext_u35';
--
SET SESSION AUTHORIZATION ext_u35;
create readable external table priv_ext_test1(a int) location ('gpfdist://@hostname@:@gp_port@/file') format 'text';  --fail 
create writable external table priv_ext_test2(a int) location ('gpfdist://@hostname@:@gp_port@/file') format 'text'; --fail
create readable external web table priv_ext_test3(a int) location ('http://@hostname@:@gp_port@/file') format 'text';  --fail

drop external table priv_ext_test1;
drop external table priv_ext_test2;
drop external table priv_ext_test3;
RESET SESSION AUTHORIZATION;
--
CREATE ROLE ext_u42 NOCREATEEXTTABLE(protocol='http',type='readable') NOCREATEEXTTABLE(protocol='http', type='readable'); 
select rolname, rolcreaterextgpfd,rolcreaterexthttp,rolcreatewextgpfd from pg_authid where rolname='ext_u42';

--
SET SESSION AUTHORIZATION ext_u42;
create readable external table priv_ext_test1(a int) location ('gpfdist://@hostname@:@gp_port@/file') format 'text';  --fail 
create writable external table priv_ext_test2(a int) location ('gpfdist://@hostname@:@gp_port@/file') format 'text'; --fail
create readable external web table priv_ext_test3(a int) location ('http://@hostname@:@gp_port@/file') format 'text';  --fail

drop external table priv_ext_test1;
drop external table priv_ext_test2;
drop external table priv_ext_test3;
RESET SESSION AUTHORIZATION;


--
-- Role to NO create RET gpfdist and NO create WET gpfdist
--
CREATE ROLE ext_u36 NOCREATEEXTTABLE(protocol='gpfdist') NOCREATEEXTTABLE(protocol='gpfdist', type='writable'); 
select rolname, rolcreaterextgpfd,rolcreaterexthttp,rolcreatewextgpfd from pg_authid where rolname='ext_u36';
--
SET SESSION AUTHORIZATION ext_u36;
create readable external table priv_ext_test1(a int) location ('gpfdist://@hostname@:@gp_port@/file') format 'text';  --fail 
create writable external table priv_ext_test2(a int) location ('gpfdist://@hostname@:@gp_port@/file') format 'text'; --fail
create readable external web table priv_ext_test3(a int) location ('http://@hostname@:@gp_port@/file') format 'text';  --fail

drop external table priv_ext_test1;
drop external table priv_ext_test2;
drop external table priv_ext_test3;
RESET SESSION AUTHORIZATION;
--
CREATE ROLE ext_u41 NOCREATEEXTTABLE(protocol='gpfdist',type='writable') NOCREATEEXTTABLE(protocol='gpfdist', type='writable'); 
select rolname, rolcreaterextgpfd,rolcreaterexthttp,rolcreatewextgpfd from pg_authid where rolname='ext_u41';
--
SET SESSION AUTHORIZATION ext_u41;
create readable external table priv_ext_test1(a int) location ('gpfdist://@hostname@:@gp_port@/file') format 'text';  --fail 
create writable external table priv_ext_test2(a int) location ('gpfdist://@hostname@:@gp_port@/file') format 'text'; --fail
create readable external web table priv_ext_test3(a int) location ('http://@hostname@:@gp_port@/file') format 'text';  --fail

drop external table priv_ext_test1;
drop external table priv_ext_test2;
drop external table priv_ext_test3;
RESET SESSION AUTHORIZATION;
--
CREATE ROLE ext_u43 NOCREATEEXTTABLE(protocol='gpfdist',type='readable') NOCREATEEXTTABLE(protocol='gpfdist', type='writable'); 
select rolname, rolcreaterextgpfd,rolcreaterexthttp,rolcreatewextgpfd from pg_authid where rolname='ext_u43';
--
SET SESSION AUTHORIZATION ext_u43;
create readable external table priv_ext_test1(a int) location ('gpfdist://@hostname@:@gp_port@/file') format 'text';  --fail 
create writable external table priv_ext_test2(a int) location ('gpfdist://@hostname@:@gp_port@/file') format 'text'; --fail
create readable external web table priv_ext_test3(a int) location ('http://@hostname@:@gp_port@/file') format 'text';  --fail

drop external table priv_ext_test1;
drop external table priv_ext_test2;
drop external table priv_ext_test3;
RESET SESSION AUTHORIZATION;
--
CREATE ROLE ext_u45 NOCREATEEXTTABLE(protocol='gpfdist',type='writable') NOCREATEEXTTABLE(protocol='gpfdist', type='readable');
select rolname, rolcreaterextgpfd,rolcreaterexthttp,rolcreatewextgpfd from pg_authid where rolname='ext_u45';

--
SET SESSION AUTHORIZATION ext_u45;
create readable external table priv_ext_test1(a int) location ('gpfdist://@hostname@:@gp_port@/file') format 'text';  --fail 
create writable external table priv_ext_test2(a int) location ('gpfdist://@hostname@:@gp_port@/file') format 'text'; --fail
create readable external web table priv_ext_test3(a int) location ('http://@hostname@:@gp_port@/file') format 'text';  --fail

drop external table priv_ext_test1;
drop external table priv_ext_test2;
drop external table priv_ext_test3;
RESET SESSION AUTHORIZATION;

--
-- Role to NO create RET gpfdist and NO create RET http
--
CREATE ROLE ext_u38 NOCREATEEXTTABLE(type='readable') NOCREATEEXTTABLE(protocol='http', type='readable'); 
select rolname, rolcreaterextgpfd,rolcreaterexthttp,rolcreatewextgpfd from pg_authid where rolname='ext_u38';
--
SET SESSION AUTHORIZATION ext_u38;
create readable external table priv_ext_test1(a int) location ('gpfdist://@hostname@:@gp_port@/file') format 'text';  --fail 
create writable external table priv_ext_test2(a int) location ('gpfdist://@hostname@:@gp_port@/file') format 'text'; --fail
create readable external web table priv_ext_test3(a int) location ('http://@hostname@:@gp_port@/file') format 'text';  --fail

drop external table priv_ext_test1;
drop external table priv_ext_test2;
drop external table priv_ext_test3;
RESET SESSION AUTHORIZATION;
--
CREATE ROLE ext_u44 NOCREATEEXTTABLE(protocol='gpfdist',type='readable') NOCREATEEXTTABLE(protocol='http', type='readable'); 
select rolname, rolcreaterextgpfd,rolcreaterexthttp,rolcreatewextgpfd from pg_authid where rolname='ext_u44';
--
--
SET SESSION AUTHORIZATION ext_u44;
create readable external table priv_ext_test1(a int) location ('gpfdist://@hostname@:@gp_port@/file') format 'text';  --fail 
create writable external table priv_ext_test2(a int) location ('gpfdist://@hostname@:@gp_port@/file') format 'text'; --fail
create readable external web table priv_ext_test3(a int) location ('http://@hostname@:@gp_port@/file') format 'text'; --fail 

drop external table priv_ext_test1;
drop external table priv_ext_test2;
drop external table priv_ext_test3;
RESET SESSION AUTHORIZATION;


--
-- Role to NO create WET gpfdist and NO create WET gpfdist
--
CREATE ROLE ext_u39 NOCREATEEXTTABLE(type='writable') NOCREATEEXTTABLE(protocol='gpfdist', type='writable'); 
select rolname, rolcreaterextgpfd,rolcreaterexthttp,rolcreatewextgpfd from pg_authid where rolname='ext_u39';

--
SET SESSION AUTHORIZATION ext_u39;
create readable external table priv_ext_test1(a int) location ('gpfdist://@hostname@:@gp_port@/writable_ext_tbl/file') format 'text';  --fail 
create writable external table priv_ext_test2(a int) location ('gpfdist://@hostname@:@gp_port@/writable_ext_tbl/output/wet_file') format 'text'; --fail
create readable external web table priv_ext_test3(a int) location ('http://@hostname@:@gp_port@/writable_ext_tbl/file') format 'text';  --fail

drop external table priv_ext_test1;
drop external table priv_ext_test2;
drop external table priv_ext_test3;
RESET SESSION AUTHORIZATION;

--
-- Role to NO create WET gpfdist and NO create RET http
--
CREATE ROLE ext_u46 NOCREATEEXTTABLE(protocol='gpfdist',type='writable') NOCREATEEXTTABLE(protocol='http', type='readable'); 
select rolname, rolcreaterextgpfd,rolcreaterexthttp,rolcreatewextgpfd from pg_authid where rolname='ext_u46';
--
SET SESSION AUTHORIZATION ext_u46;
create readable external table priv_ext_test1(a int) location ('gpfdist://@hostname@:@gp_port@/file') format 'text';   --fail
create writable external table priv_ext_test2(a int) location ('gpfdist://@hostname@:@gp_port@/file') format 'text'; --fail
create readable external web table priv_ext_test3(a int) location ('http://@hostname@:@gp_port@/file') format 'text';  --fail

drop external table priv_ext_test1;
drop external table priv_ext_test2;
drop external table priv_ext_test3;
RESET SESSION AUTHORIZATION;

SET SESSION AUTHORIZATION ext_u1;
create readable external table priv_ext_test3(a int) location ('gpfdist://@hostname@:@gp_port@/file') format 'text';
select * from priv_ext_test3 order by a;
RESET SESSION AUTHORIZATION;
ALTER ROLE ext_u1 NOCREATEEXTTABLE(protocol='gpfdist', type='readable');
SET SESSION AUTHORIZATION ext_u1;
create readable external table priv_ext_test4(a int) location ('gpfdist://@hostname@:@gp_port@/file') format 'text'; -- fail
RESET SESSION AUTHORIZATION;

drop external table priv_ext_test3;

SET SESSION AUTHORIZATION ext_u2;
create writable external table priv_ext_test3(a int) location ('gpfdist://@hostname@:@gp_port@/output/wet_file') format 'text';
insert into priv_ext_test3 values (generate_series(1,10));
RESET SESSION AUTHORIZATION;
ALTER ROLE ext_u2 NOCREATEEXTTABLE(protocol='gpfdist', type='writable');
SET SESSION AUTHORIZATION ext_u2;
create writable external table priv_ext_test4(a int) location ('gpfdist://@hostname@:@gp_port@/file') format 'text'; -- fail
RESET SESSION AUTHORIZATION;

drop external table priv_ext_test3;


SET SESSION AUTHORIZATION ext_u3;
create readable external web table priv_ext_test3(a int) location ('http://@hostname@:@gp_port@/file') format 'text';
select * from priv_ext_test3 order by a;
RESET SESSION AUTHORIZATION;
ALTER ROLE ext_u3 NOCREATEEXTTABLE(protocol='http', type='readable');
SET SESSION AUTHORIZATION ext_u3;
create readable external web table priv_ext_test4(a int) location ('http://@hostname@:@gp_port@/file') format 'text'; -- fail
RESET SESSION AUTHORIZATION;

drop external table priv_ext_test3;

SET SESSION AUTHORIZATION ext_u34;
create readable external table priv_ext_test3(a int) location ('gpfdist://@hostname@:@gp_port@/file') format 'text'; -- fail
RESET SESSION AUTHORIZATION;
ALTER ROLE ext_u34 CREATEEXTTABLE(protocol='gpfdist', type='readable');
SET SESSION AUTHORIZATION ext_u34;
create readable external table priv_ext_test4(a int) location ('gpfdist://@hostname@:@gp_port@/file') format 'text'; 
select * from priv_ext_test4 order by a;
RESET SESSION AUTHORIZATION;

drop external table priv_ext_test4;
SET SESSION AUTHORIZATION ext_u39;
create writable external table priv_ext_test3(a int) location ('gpfdist://@hostname@:@gp_port@/file') format 'text'; -- fail
RESET SESSION AUTHORIZATION;
ALTER ROLE ext_u39 CREATEEXTTABLE(protocol='gpfdist', type='writable');
SET SESSION AUTHORIZATION ext_u39;
create writable external table priv_ext_test4(a int) location ('gpfdist://@hostname@:@gp_port@/output/wet_file') format 'text'; 
insert into priv_ext_test4 values (generate_series(1,10));
RESET SESSION AUTHORIZATION;

drop external table priv_ext_test4;
SET SESSION AUTHORIZATION ext_u35;
create readable external web table priv_ext_test3(a int) location ('http://@hostname@:@gp_port@/file') format 'text'; -- fail
RESET SESSION AUTHORIZATION;
ALTER ROLE ext_u35 CREATEEXTTABLE(protocol='http', type='readable');
SET SESSION AUTHORIZATION ext_u35;
create readable external web table priv_ext_test4(a int) location ('http://@hostname@:@gp_port@/file') format 'text'; 
select * from priv_ext_test4 order by a;
RESET SESSION AUTHORIZATION;

drop external table priv_ext_test4;
