#!/usr/sbin/dtrace -s

#pragma D option quiet
#pragma D option switchrate=2997hz
#pragma D option dynvarsize=8m

/*
 * This script trace disk io from g_disk_start to g_disk_done.
 * Both functions have only one argument of type struct bio *.
 * But since we only enter g_disk_done after the disk finish
 * reading the data and generate an interrupr, there is no
 * guarantee that the two bio's are the same. After a lot of
 * experiments, I end up with the following identifiers.
 * Also, note that while this->bio->bio_to->name and
 * this->bio->bio_disk->d_geom->name may refer to the same
 * da2, they are only equal when we take stringof them.
 * The high switchrate of this scripts is due to the high
 * collisions of the array with our current keys.
 * See <sys/bio.h>, <geom/geom.h> and <geom/geom_disk.h>.
 */

BEGIN
{
        bio_cmd[0] = "0";
        bio_cmd[1] = "Read";
        bio_cmd[2] = "Write";
        bio_cmd[3] = "Delete";
        bio_cmd[4] = "Getattr";
        bio_cmd[5] = "Flush";
	min_ns = 1000000;
}

fbt::zfs_freebsd_read:entry, fbt::zfs_freebsd_write:entry
/this->fi_name != "unknown" && execname != "python3.7"/
{

    /* http://svn0.us-west.freebsd.org/base/vendor/dtracetoolkit/dist/Snippits/fd2pathname.txt
    this->filep =
    curthread->t_procp->p_user.u_finfo.fi_list[this->fd].uf_file;
    this->vnodep = this->filep != 0 ? this->filep->f_vnode : 0;
    self->vpath = this->vnodep ? (this->vnodep->v_path != 0 ?
        cleanpath(this->vnodep->v_path) : "<unknown>") : "<unknown>";*/

    this->vp = args[0]->a_vp;
    this->ncp = this->vp != NULL ? (&(this->vp->v_cache_dst) != NULL ?
            this->vp->v_cache_dst.tqh_first : 0) : 0;
    this->fi_name = this->ncp ? (this->ncp->nc_name != 0 ?
            stringof(this->ncp->nc_name) : "<unknown>") : "<unknown>";

    self->path = this->fi_name; /* args[0]->v_path; */
    /*printf("0x%x", args[0]); */
    /* TODO Put kb back in... */
    /*self->kb = args[1]->uio_resid / 1024;*/
    self->start = timestamp;
}

fbt::zfs_freebsd_read:return, fbt::zfs_freebsd_write:return
/self->start && (timestamp - self->start) >= min_ns && execname != "python3.7"/
{
    this->iotime = (timestamp - self->start) / 1000000;
    this->dir = probefunc == "zfs_freebsd_read" ? "ZFS-R" : "ZFS-W";
    @zlat[stringof(execname), this->dir] = quantize(this->iotime);
}
fbt::zfs_freebsd_read:return, fbt::zfs_freebsd_write:return
{
    self->path = 0; self->kb = 0; self->start = 0;
}


fbt::nfs_read:entry, fbt::nfs_bwrite:entry
/this->fi_name != "unknown" && execname != "python3.7"/
{

    /* http://svn0.us-west.freebsd.org/base/vendor/dtracetoolkit/dist/Snippits/fd2pathname.txt
    this->filep =
    curthread->t_procp->p_user.u_finfo.fi_list[this->fd].uf_file;
    this->vnodep = this->filep != 0 ? this->filep->f_vnode : 0;
    self->vpath = this->vnodep ? (this->vnodep->v_path != 0 ?
        cleanpath(this->vnodep->v_path) : "<unknown>") : "<unknown>";*/

    this->fi_name = this->ncp ? (this->ncp->nc_name != 0 ?
            stringof(this->ncp->nc_name) : "<unknown>") : "<unknown>";

    self->path = this->fi_name; /* args[0]->v_path; */
    self->start = timestamp;
}

/*fbt::nfs_read:return, fbt::nfs_bwrite:return*/
fbt::nfs_read:return
/self->start && (timestamp - self->start) >= min_ns && execname != "python3.7"/
{
    this->iotime = (timestamp - self->start) / 1000000;
    this->dir = probefunc == "nfs_read" ? "NFS-R" : "NFS-W";
    @nlat[stringof(execname), this->dir] = quantize(this->iotime);
}
/*fbt::nfs_read:return, fbt::nfs_write:return */
fbt::nfs_read:return
{
    self->path = 0; self->kb = 0; self->start = 0;
}



fbt::g_disk_start:entry
/args[0]->bio_cmd == 1/
{
        this->bio = (struct bio *)arg0;
}

fbt::g_disk_start:entry
/args[0]->bio_cmd == 1/
{
        this->s_name = stringof(this->bio->bio_to->name);
        ddn[this->bio->bio_data, this->s_name, this->bio->bio_cmd] = timestamp;
        @start = count();
}

fbt::g_disk_done:entry
/(this->bio = (struct bio *)arg0) &&
(this->name = this->bio->bio_disk->d_geom->name) &&
(this->ts = ddn[this->bio->bio_data, stringof(this->name), this->bio->bio_cmd]) &&
(args[0]->bio_cmd == 1)/
{
        this->op = bio_cmd[this->bio->bio_cmd];
        @lat[stringof(this->name), this->op] = quantize((timestamp - this->ts)/(1000*1000));
        @iosize[stringof(this->name), this->op] = quantize(this->bio->bio_bcount);
        ddn[this->bio->bio_data, stringof(this->name), this->bio->bio_cmd] = 0;
        @end = count();
}

tick-10s
/* tick-1s */
{
        printf("Latencies (ms)\n\n");
        printa("%s %s %@d\n", @lat);
        printa("%s %s %@d\n", @zlat);
        printa("%s %s %@d\n", @nlat);
        /*printf("IO sizes (bytes)\n\n");
        printa("%s %s %@d\n", @iosize);
        printf("Booking keeping\n");
        printa(@start, @end);*/
        printf("------------------------------------------------\n\n");
        trunc(@lat);
        trunc(@zlat);
        trunc(@nlat);
        trunc(@iosize);
        trunc(@start);
        trunc(@end);
}
