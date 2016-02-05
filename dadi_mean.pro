



function dadi_mean,x
  ;help,x
  sigma=stddev(x,/double)
  x_dev=x-mean(x)
  ind=where(abs(x_dev) lt 3*sigma)
  x_out=x[ind]
  ;help,x_out
  return,mean(x_out)

end
