#define GET_DVP(pt) \
this->dvp = pt->nc_dvp != NULL ? \
(&(pt->nc_dvp->v_cache_dst) != NULL ? \
pt->nc_dvp->v_cache_dst.tqh_first : 0) : 0;

#define GET_NCP \
this->ncp = &(args[0]->v_cache_dst) != NULL ? \
args[0]->v_cache_dst.tqh_first : 0;

#define NC_NAME(pt1, pt2) \
pt1 = pt2 != 0 ? (pt2->nc_name != 0 ? \
stringof(pt2->nc_name): "<none>") : "<none>";

#define GET_DIR_NAME(pt) \
ENTRY_PROBES \
/this->dvp && execname != "dtrace" && \
($$1 == NULL || $$1 == execname)/ \
{ \
        GET_DVP(this->dvp); \
        NC_NAME(pt, this->dvp); \
}


#define PRINT_DIR_NAME(dn) \
ENTRY_PROBES \
/dn != 0 && dn != "<none>" && execname != "dtrace" && \
($$1 == NULL || $$1 == execname) && this->fi_mount != "/dev"/ \
{ \
        printf("%s/", dn); \
	dn = 0; \
}

PRINT_DIR_NAME(this->fi_dirname)
