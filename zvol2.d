#!/usr/sbin/dtrace -Cs

#pragma D option quiet

fbt:kernel:zvol_strategy:entry
{
  print("hi\n");
  this->buf = (struct bio *)arg0;
  this->minor = ((this->buf->bio_dev));
  @cnt[this->minor, this->buf->bio_cmd == BIO_READ ? "R" : "W"] = count();
}
