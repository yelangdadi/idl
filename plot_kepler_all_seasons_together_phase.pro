;kepler画图程序
;上图全BJD图，左下图phase全数据图，右下图phase合并图
;20151103




pro plot_kepler_all_seasons_together_phase
  
  
  ;读20150125的全信息表catalogue
  catalog_txt='E:\Kepler_EclipsingBinary\Catalog\kepler_EBs_catalog_20151025\all\keplerebs.villanova.edu_20151025.txt' 
  readcol,catalog_txt,InCat,KIC,camp,KOI1,Mult,period,period_err,bjd0,bjd0_err,pdepth,sdepth,pwidth,swidth,sep,morph,T2T1,rho1rho2,q,e_sin_omega,e_cos_omega,FF,sin_i,RA,DEC,GLon,GLat,kmag,Teff,Teff_Pinsonneault,Teff_Casagrande,KOI,SC,ETV, $ 
               format='(  A,  L,   A,   L,   L,     D,         D,   D,       D,     D,     D,     D,     D,  D,    D,   D,       D,D,          D,          D, D,    D, D,  D,   D,   D,   D,   D,                D,              D,  A, A,  A)',/silent           
  KIC_cata=string(KIC,format='(I09)') ;得到9位的kic  
  
  
  ;设置文件夹--包括数据来源文件夹和存图文件夹
  root_dir_dats='E:\Kepler_EclipsingBinary\EclipsingBinary_dats_and_pngs\EclipsingBinary_20151027_dats'
  png_dir='E:\Kepler_EclipsingBinary\EclipsingBinary_dats_and_pngs\png5\all_in_one_llc_20151203_order3_sectionfit_phase_s'
  ;获得每个KIC的数据文件夹名字  
  dir_names=FILE_SEARCH(root_dir_dats+PATH_SEP()+'*_KIC*',COUNT=num_kicname,/FULLY_QUALIFY_PATH) ;已经是独数  
  basenames=FILE_BASENAME(dir_names)
  kic_names=STRMID(basenames,18,9) ;获得文件名中的KIC
  
  
  
  
  for i = 0L, num_kicname-1 do begin
    
    
    ;得到长段数据的个数
    file_llc=FILE_SEARCH(dir_names[i]+PATH_SEP()+'*llc.fits.dat',COUNT=num_llc,/FULLY_QUALIFY_PATH)
    file_slc=FILE_SEARCH(dir_names[i]+PATH_SEP()+'*slc.fits.dat',COUNT=num_slc,/FULLY_QUALIFY_PATH)
    ;对于某个KIC，获得星表中的标号
    ind_catalog=where(KIC_cata eq kic_names[i],num_catalog) ;在星表中某个KIC对应的标号
    ind_true=where(InCat[ind_catalog] eq 'True',num_true) ;在星表中第一个入表周期（如果有）KIC对应的标号，如果没有入表周期，则是最后一个周期的标号
    ind_period=ind_catalog[ind_true[0]] ;入表周期的标号（如果有）
    ;获得存图的标题
    titlename= $    
    '      P=' +STRTRIM(string(period[ind_period] ,format='(D13.8)'),2) + $   ;入表周期
    '    Teff=' +STRTRIM(string(  Teff[ind_catalog[0]]          ,format='(I6)'   ),2) + $   ;温度
    '    Kmag=' +STRTRIM(string(  kmag[ind_catalog[0]]          ,format='(D8.3)' ),2) + $   ;星等
    '    morph='+STRTRIM(string( morph[ind_catalog[0]]          ,format='(D5.2)' ),2) + $   ;双星类型
    '    num_ls=' +STRTRIM(string( num_llc                      ,format='(I2)')   ,2) + $   ;长段数据个数
    '/'         +STRTRIM(string(   num_slc                      ,format='(I2)')   ,2) + $   ;短段数据个数
    '    num_P='  +STRTRIM(string( Mult[ind_catalog[0]]         ,format='(I2)')   ,2) + $   ;入表周期个数
    '/'         +STRTRIM(string( num_catalog                    ,format='(I2)')   ,2)       ;总周期个数
    print,i+1,'/2593   ',kic_names[i],'     ',titlename,'  ',sep[ind_period],'  ',pwidth[ind_period]  ;在屏幕上输出    
    
    
    
    
    ;获得存图的文件名
    png_name=png_dir+PATH_SEP()+'P='+STRTRIM(string(period[ind_catalog[ind_true[0]]],format='(D013.8)'),2)+'_'+'KIC'+kic_names[i]+'_AllInOne.png'
        if ((FILE_INFO(png_name)).EXISTS eq 1) then continue    ;如果png图像已经存在，那么跳到下一循环
        if (num_slc eq 0) then continue
    ;得到平直后的全部BJD和PDC_flux
    read_one_kic_lcs,dir_names[i],cadence='s',BJD=BJD,PDC_flux=PDC_flux,flatten=1,order_flatten=3
    ;画图--上图为全BJD图，左下图为phase全数据图，右下图为bin后的phase图
    p=plot(BJD,2.5*alog10(PDC_flux),LINESTYLE=6,SYMBOL='+',XTITLE='BJD - 2454833',YTITLE='-mag',TITLE='KIC'+kic_names[i]+titlename,POSITION=[0.1,0.55,0.95,0.95],DIMENSIONS=[1550,1000],BUFFER=1)
        addplot_kepler_seasons_border,p_out=p,color='green' ;画每个季度的边界线
    ;得到phase并画图
    calculate_phase_of_kepler_data,BJD=BJD,P0=period[ind_period],T0=bjd0[ind_period]-54833,flux_in=PDC_flux,phase_out=phase_out,flux_out=flux_out,bin=0
        phase_out=[phase_out-1,phase_out,phase_out+1] & flux_out=[flux_out,flux_out,flux_out]
    p=plot(phase_out,2.5*alog10(flux_out),LINESTYLE=6,SYMBOL='+',XTITLE='phase',YTITLE='-mag',XRANGE=[-0.2,1.2],POSITION=[0.10,0.05,0.50,0.50],/CURRENT,BUFFER=1)
    ;得到合并的phase并画图
    calculate_phase_of_kepler_data,BJD=BJD,P0=period[ind_period],T0=bjd0[ind_period]-54833,flux_in=PDC_flux,phase_out=phase_out,flux_out=flux_out,bin=1,  $
                                   num_point=300,num_min_point=max([300,period[ind_period]/0.001]),dense_phase=sep[ind_period],dense_width=pwidth[ind_period]
        phase_out=[phase_out-1,phase_out,phase_out+1] & flux_out=[flux_out,flux_out,flux_out]
    p=plot(phase_out,2.5*alog10(flux_out),LINESTYLE=6,SYMBOL='+',XTITLE='phase',YTITLE='-mag',XRANGE=[-0.2,1.2],POSITION=[0.60,0.05,0.95,0.50],/CURRENT,BUFFER=1)
    ;存图
    p.save,png_name,RESOLUTION=100
    p.close    
    
    
  endfor
  
  
end
