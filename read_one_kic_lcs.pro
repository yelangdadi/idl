;功能型模块，读取某个kic的所有lc数据，分slc和llc。
;得到BJD和PDC_flux及误差err
;通过flatten参数设置是否进行平直和归一化操作
;
;内部参数：file_name定义中有'lc.fits.dat'部分，根据需要要改


pro read_one_kic_lcs,dir,cadence=cadence,BJD=BJD,PDC_flux=PDC_flux,err=err,flatten=flatten,count=count,num_llc=num_llc,num_slc=num_slc,order_flatten=order_flatten, $
                         suffix=suffix
  
  
  ;检查cadence参数是否合法
  if ((cadence ne 's') and (cadence ne 'l')) then begin
    print,'input parameter cadence wrong!'
    stop,cadence
  endif
  
  ;查看文件名后缀
  if (~keyword_set(suffix)) then suffix='.fits.dat'  ;如果没有指定，则为dat后缀
  
  ;得到长短段数据文件的个数
  file_llc=FILE_SEARCH(dir+PATH_SEP()+'*llc'+suffix,COUNT=num_llc,/FULLY_QUALIFY_PATH)
  file_slc=FILE_SEARCH(dir+PATH_SEP()+'*slc'+suffix,COUNT=num_slc,/FULLY_QUALIFY_PATH)
  
  ;获得文件名列表
  file_name=FILE_SEARCH(dir+PATH_SEP()+'*'+cadence+'lc'+suffix,COUNT=count,/FULLY_QUALIFY_PATH)
  
  ;如果没有文件则结束
  if (count eq 0) then goto,dne
  
  ;读取文件同时平滑
  time_all=[] & flux_all=[] & fluxerr_all=[]  
  for i = 0L, count-1 do begin
    read_data_from_one_fits,file_name[i],BJD=time,PDC_FLUX=flux
    
    ;进行拉直操作
    sep=time[1:*]-time[0:-2] ;记录相邻两点的间隔，sep的元素数比time少1
    ind_split=where(sep gt 1,num_split) ;得到分段点的标号 （分段的判断标准为1天，这里需要手动调整！！！）
    ind_split=[-1,ind_split,-2] ;增加标号，为了下面的循环方便
    for ii = 0L, (num_split+1)-1 do begin ;分段拟合 （注意循环范围设置）
      time_section=time[(ind_split[ii]+1):ind_split[ii+1]] ;标号的使用利用IDL标号-1规定。
      flux_section=flux[(ind_split[ii]+1):ind_split[ii+1]]
      
      if (KEYWORD_SET(flatten)) then begin ;平直化
        ;flux=flux/mean(flux) ;简单归一化加平移处理
        flatten_kepler_data_use_polyfit_of_sigclip,BJD=time_section,PDC_FLUX=flux_section,FLUX_OUT=FLUX_OUT,num_clip=10,order=order_flatten
      endif else begin
        flux_out=flux_section
      endelse
      
      time_all=[time_all,time_section]
      flux_all=[flux_all,flux_out] 
    endfor
  endfor
  
  ;得到输出值
  BJD=time_all
  PDC_flux=flux_all
  
  
  
  
dne:
end
