;功能性程序
;从某个fits文件中读出time和PDC_flux
;注意，此程序带有剔除高弥散点功能，慎用！--已删除20140716


pro read_data_from_one_fits,file_name,BJD=BJD,PDC_FLUX=PDC_FLUX,fluxerr=fluxerr
  
  suffix=STRMID(file_name,STRPOS(file_name,'.',/REVERSE_SEARCH)+1) ;得到后缀
  if (suffix eq 'fits') then begin
  
    ftab_ext,file_name,'TIME,PDCSAP_FLUX,PDCSAP_FLUX_ERR',TIME,PDCSAP_FLUX,PDCSAP_FLUX_ERR
  
    ;得到非NaN数据
    ind_valid=where(FINITE(PDCSAP_FLUX)) ;得到非NaN数据的标号
    
    ;输出值
    BJD=TIME[ind_valid]
    PDC_FLUX=PDCSAP_FLUX[ind_valid]
    fluxerr=PDCSAP_FLUX_ERR[ind_valid]
    
  endif else begin
  
    readcol,file_name,BJD,PDC_FLUX,fluxerr,FORMAT='(D,D,D)',/silent
    
  endelse  

  
  
end
