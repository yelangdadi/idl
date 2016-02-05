;对数据进行多项式拟合，只被read_one_kic_lcs调用以拉平数据
;xfit,yfit也做输出，为了特殊定制目的

pro flatten_kepler_data_use_polyfit_of_sigclip,BJD=BJD,PDC_FLUX=PDC_FLUX,FLUX_OUT=FLUX_OUT,num_clip=num_clip,order=order,xfit=xfit,yfit=yfit
  
  
;  ;手动指定输入值
;  file='E:\Kepler_EclipsingBinary\EclipsingBinary_dats_and_pngs\EclipsingBinary_20130816_dats\P0005.87712800_kplr007376500\kplr007376500-2011177032512_llc.fits.dat'
;  readcol,file,BJD,PDC_FLUX,fluxerr,FORMAT='(D,D,D)',/silent
;  num_clip=10 & order=3
  
  ;存入内部变量
  x=BJD-min(BJD)
  y=PDC_FLUX
  
  ;多项式拟合
  for i = 0L, num_clip-1 do begin
    coeff=POLY_FIT(x,y,order,YFIT=yfit0,/DOUBLE,YERROR=YERROR)
    ind=where(abs(y-yfit0) lt 3*YERROR) ;s使用3倍标准差值
    if (N_ELEMENTS(x) eq N_ELEMENTS(x[ind])) then break ;如果没有剔除点则跳出
    x=x[ind] & y=y[ind]
  endfor
  
  ;得到拟合曲线
  xfit=scale_array(DINDGEN(1000),0,max(BJD-min(BJD)))
  yfit=0 & for i = 0L, order do yfit=yfit+(xfit^i)*coeff[i]
  
  ;得到平直后的FLUX
  FLUX_fit = INTERPOL(yfit, xfit, BJD-min(BJD))
  FLUX_out=PDC_FLUX/FLUX_fit
  
;  ;画图查看
;  p=plot(BJD-min(BJD),PDC_FLUX,LINESTYLE=6,SYMBOL='+')
;  p=plot(x,y,LINESTYLE=6,SYMBOL='+',COLOR='green',/OVERPLOT)
;  p=plot(xfit,yfit,/OVERPLOT)
  
  
end
