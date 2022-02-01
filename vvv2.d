# 1 "vfssnoop2.d"
# 1 "<built-in>" 1
# 1 "<built-in>" 3
# 338 "<built-in>" 3
# 1 "<command line>" 1
# 1 "<built-in>" 2
# 1 "vfssnoop2.d" 2
# 24 "vfssnoop2.d"
#pragma D option quiet
#pragma D option defaultargs
#pragma D option switchrate=20hz
#pragma D option bufsize=8m
#pragma D option dynvarsize=32m
# 94 "vfssnoop2.d"
BEGIN
{
        printf("%-16s %6s %6s %-16.16s %-12s %8s %s\n", "TIMESTAMP",
 "UID", "PID", "PROCESS", "CALL", "SIZE", "PATH/FILE");
}







vfs::vop_read:entry, vfs::vop_write:entry
/execname != "dtrace" && ($$1 == NULL || $$1 == execname)/
{
        this->bytes = args[1]->a_uio->uio_resid;
        this->kbytes = this->bytes / 1024;
        this->mbytes = this->bytes / 1048576;
        this->unit = this->kbytes != 0 ? "K" :
  (this->mbytes != 0 ? "M" : "B");
        this->number = this->kbytes != 0 ? this->kbytes :
  (this->mbytes != 0 ? this->mbytes : this->bytes);
}

vfs::vop_create:entry, vfs::vop_remove:entry, vfs::vop_mkdir:entry, vfs::vop_rmdir:entry, vfs::vop_getattr:entry, vfs::vop_open:entry, vfs::vop_close:entry, vfs::vop_fsync:entry
/execname != "dtrace" && ($$1 == NULL || $$1 == execname)/
{
        this->unit = "-";
}






vfs::vop_create:entry, vfs::vop_remove:entry, vfs::vop_mkdir:entry, vfs::vop_rmdir:entry
/execname != "dtrace" && ($$1 == NULL || $$1 == execname)/
{
 this->ncp = &(args[0]->v_cache_dst) != NULL ? args[0]->v_cache_dst.tqh_first : 0;;
        this->fi_mount = args[0]->v_mount ?
  stringof(args[0]->v_mount->mnt_stat.f_mntonname) :
   "<none>";
        this->fi_dirname = this->ncp != 0 ? (this->ncp->nc_name != 0 ? stringof(this->ncp->nc_name): "<none>") : "<none>";;




        this->fi_name = args[1]->a_cnp->cn_nameptr != NULL ?
  stringof(args[1]->a_cnp->cn_nameptr) : "<unknown>";
}






vfs::vop_create:entry, vfs::vop_remove:entry, vfs::vop_mkdir:entry, vfs::vop_rmdir:entry
/this->ncp && execname != "dtrace" && ($$1 == NULL || $$1 == execname)/
{
        this->dvp = this->ncp->nc_dvp != NULL ? (&(this->ncp->nc_dvp->v_cache_dst) != NULL ? this->ncp->nc_dvp->v_cache_dst.tqh_first : 0) : 0;;
        this->dn1 = this->dvp != 0 ? (this->dvp->nc_name != 0 ? stringof(this->dvp->nc_name): "<none>") : "<none>";;
}

vfs::vop_read:entry, vfs::vop_write:entry, vfs::vop_getattr:entry, vfs::vop_open:entry, vfs::vop_close:entry, vfs::vop_fsync:entry
/execname != "dtrace" && ($$1 == NULL || $$1 == execname)/
{






        this->ncp = &(args[0]->v_cache_dst) != NULL ? args[0]->v_cache_dst.tqh_first : 0;;
        this->fi_mount = args[0]->v_mount ?
  stringof(args[0]->v_mount->mnt_stat.f_mntonname) :
   "<none>";
        this->fi_name = this->ncp ? (this->ncp->nc_name != 0 ?
  stringof(this->ncp->nc_name) : "<unknown>") : "<unknown>";
 this->fi_dirname = "<none>";
}

vfs::vop_read:entry, vfs::vop_write:entry, vfs::vop_getattr:entry, vfs::vop_open:entry, vfs::vop_close:entry, vfs::vop_fsync:entry
/this->ncp && execname != "dtrace" && ($$1 == NULL || $$1 == execname)/
{
        this->dvp = this->ncp->nc_dvp != NULL ? (&(this->ncp->nc_dvp->v_cache_dst) != NULL ? this->ncp->nc_dvp->v_cache_dst.tqh_first : 0) : 0;;
        this->fi_dirname = this->dvp != 0 ? (this->dvp->nc_name != 0 ? stringof(this->dvp->nc_name): "<none>") : "<none>";;
}

vfs::vop_read:entry, vfs::vop_write:entry, vfs::vop_getattr:entry, vfs::vop_open:entry, vfs::vop_close:entry, vfs::vop_fsync:entry
/this->dvp && execname != "dtrace" && ($$1 == NULL || $$1 == execname)/
{
        this->dvp = this->dvp->nc_dvp != NULL ? (&(this->dvp->nc_dvp->v_cache_dst) != NULL ? this->dvp->nc_dvp->v_cache_dst.tqh_first : 0) : 0;;
        this->dn1 = this->dvp != 0 ? (this->dvp->nc_name != 0 ? stringof(this->dvp->nc_name): "<none>") : "<none>";;
}






vfs::vop_read:entry, vfs::vop_write:entry, vfs::vop_create:entry, vfs::vop_remove:entry, vfs::vop_mkdir:entry, vfs::vop_rmdir:entry, vfs::vop_getattr:entry, vfs::vop_open:entry, vfs::vop_close:entry, vfs::vop_fsync:entry /this->dvp && execname != "dtrace" && ($$1 == NULL || $$1 == execname)/ { this->dvp = this->dvp->nc_dvp != NULL ? (&(this->dvp->nc_dvp->v_cache_dst) != NULL ? this->dvp->nc_dvp->v_cache_dst.tqh_first : 0) : 0;; this->dn2 = this->dvp != 0 ? (this->dvp->nc_name != 0 ? stringof(this->dvp->nc_name): "<none>") : "<none>";; }
vfs::vop_read:entry, vfs::vop_write:entry, vfs::vop_create:entry, vfs::vop_remove:entry, vfs::vop_mkdir:entry, vfs::vop_rmdir:entry, vfs::vop_getattr:entry, vfs::vop_open:entry, vfs::vop_close:entry, vfs::vop_fsync:entry /this->dvp && execname != "dtrace" && ($$1 == NULL || $$1 == execname)/ { this->dvp = this->dvp->nc_dvp != NULL ? (&(this->dvp->nc_dvp->v_cache_dst) != NULL ? this->dvp->nc_dvp->v_cache_dst.tqh_first : 0) : 0;; this->dn3 = this->dvp != 0 ? (this->dvp->nc_name != 0 ? stringof(this->dvp->nc_name): "<none>") : "<none>";; }
vfs::vop_read:entry, vfs::vop_write:entry, vfs::vop_create:entry, vfs::vop_remove:entry, vfs::vop_mkdir:entry, vfs::vop_rmdir:entry, vfs::vop_getattr:entry, vfs::vop_open:entry, vfs::vop_close:entry, vfs::vop_fsync:entry /this->dvp && execname != "dtrace" && ($$1 == NULL || $$1 == execname)/ { this->dvp = this->dvp->nc_dvp != NULL ? (&(this->dvp->nc_dvp->v_cache_dst) != NULL ? this->dvp->nc_dvp->v_cache_dst.tqh_first : 0) : 0;; this->dn4 = this->dvp != 0 ? (this->dvp->nc_name != 0 ? stringof(this->dvp->nc_name): "<none>") : "<none>";; }
vfs::vop_read:entry, vfs::vop_write:entry, vfs::vop_create:entry, vfs::vop_remove:entry, vfs::vop_mkdir:entry, vfs::vop_rmdir:entry, vfs::vop_getattr:entry, vfs::vop_open:entry, vfs::vop_close:entry, vfs::vop_fsync:entry /this->dvp && execname != "dtrace" && ($$1 == NULL || $$1 == execname)/ { this->dvp = this->dvp->nc_dvp != NULL ? (&(this->dvp->nc_dvp->v_cache_dst) != NULL ? this->dvp->nc_dvp->v_cache_dst.tqh_first : 0) : 0;; this->dn5 = this->dvp != 0 ? (this->dvp->nc_name != 0 ? stringof(this->dvp->nc_name): "<none>") : "<none>";; }

vfs::vop_read:entry, vfs::vop_write:entry
/execname != "dtrace" && ($$1 == NULL || $$1 == execname)/
{
 this->mountnm = this->fi_mount != "/" ? this->fi_mount : "\0";
 printf("%-16d %6d %6d %-16.16s %-12s %7d%s %s/", timestamp, uid,
  pid, execname, probefunc, this->number, this->unit,
                 this->mountnm);
}

vfs::vop_create:entry, vfs::vop_remove:entry, vfs::vop_mkdir:entry, vfs::vop_rmdir:entry, vfs::vop_getattr:entry, vfs::vop_open:entry, vfs::vop_close:entry, vfs::vop_fsync:entry
/execname != "dtrace" && ($$1 == NULL || $$1 == execname)/
{
 this->mountnm = this->fi_mount != "/" ? this->fi_mount : "\0";
 printf("%-16d %6d %6d %-16.16s %-12s %8s %s/", timestamp, uid,
  pid, execname, probefunc, this->unit, this->mountnm);
}

vfs::vop_read:entry, vfs::vop_write:entry, vfs::vop_create:entry, vfs::vop_remove:entry, vfs::vop_mkdir:entry, vfs::vop_rmdir:entry, vfs::vop_getattr:entry, vfs::vop_open:entry, vfs::vop_close:entry, vfs::vop_fsync:entry /this->dn5 != 0 && this->dn5 != "<none>" && execname != "dtrace" && ($$1 == NULL || $$1 == execname) && this->fi_mount != "/dev"/ { printf("%s/", this->dn5); this->dn5 = 0; }
vfs::vop_read:entry, vfs::vop_write:entry, vfs::vop_create:entry, vfs::vop_remove:entry, vfs::vop_mkdir:entry, vfs::vop_rmdir:entry, vfs::vop_getattr:entry, vfs::vop_open:entry, vfs::vop_close:entry, vfs::vop_fsync:entry /this->dn4 != 0 && this->dn4 != "<none>" && execname != "dtrace" && ($$1 == NULL || $$1 == execname) && this->fi_mount != "/dev"/ { printf("%s/", this->dn4); this->dn4 = 0; }
vfs::vop_read:entry, vfs::vop_write:entry, vfs::vop_create:entry, vfs::vop_remove:entry, vfs::vop_mkdir:entry, vfs::vop_rmdir:entry, vfs::vop_getattr:entry, vfs::vop_open:entry, vfs::vop_close:entry, vfs::vop_fsync:entry /this->dn3 != 0 && this->dn3 != "<none>" && execname != "dtrace" && ($$1 == NULL || $$1 == execname) && this->fi_mount != "/dev"/ { printf("%s/", this->dn3); this->dn3 = 0; }
vfs::vop_read:entry, vfs::vop_write:entry, vfs::vop_create:entry, vfs::vop_remove:entry, vfs::vop_mkdir:entry, vfs::vop_rmdir:entry, vfs::vop_getattr:entry, vfs::vop_open:entry, vfs::vop_close:entry, vfs::vop_fsync:entry /this->dn2 != 0 && this->dn2 != "<none>" && execname != "dtrace" && ($$1 == NULL || $$1 == execname) && this->fi_mount != "/dev"/ { printf("%s/", this->dn2); this->dn2 = 0; }
vfs::vop_read:entry, vfs::vop_write:entry, vfs::vop_create:entry, vfs::vop_remove:entry, vfs::vop_mkdir:entry, vfs::vop_rmdir:entry, vfs::vop_getattr:entry, vfs::vop_open:entry, vfs::vop_close:entry, vfs::vop_fsync:entry /this->dn1 != 0 && this->dn1 != "<none>" && execname != "dtrace" && ($$1 == NULL || $$1 == execname) && this->fi_mount != "/dev"/ { printf("%s/", this->dn1); this->dn1 = 0; }
vfs::vop_read:entry, vfs::vop_write:entry, vfs::vop_create:entry, vfs::vop_remove:entry, vfs::vop_mkdir:entry, vfs::vop_rmdir:entry, vfs::vop_getattr:entry, vfs::vop_open:entry, vfs::vop_close:entry, vfs::vop_fsync:entry /this->fi_dirname != 0 && this->fi_dirname != "<none>" && execname != "dtrace" && ($$1 == NULL || $$1 == execname) && this->fi_mount != "/dev"/ { printf("%s/", this->fi_dirname); this->fi_dirname = 0; }

vfs::vop_read:entry, vfs::vop_write:entry, vfs::vop_create:entry, vfs::vop_remove:entry, vfs::vop_mkdir:entry, vfs::vop_rmdir:entry, vfs::vop_getattr:entry, vfs::vop_open:entry, vfs::vop_close:entry, vfs::vop_fsync:entry
/execname != "dtrace" && ($$1 == NULL || $$1 == execname)/
{
 printf("%s\n", this->fi_name);
}
