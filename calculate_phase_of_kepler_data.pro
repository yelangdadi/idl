;被plot_kepler_all_seasons_together_phase调用，用于计算相位光变曲线，或则合并后的相位光变曲线。
;20150528大改 去掉了原来自动寻找次极小的功能


pro calculate_phase_of_kepler_data,BJD=BJD,P0=P0,T0=T0,flux_in=flux_in,phase_out=phase_out,flux_out=flux_out,  $
                                   bin=bin,num_point=num_point,num_min_point=num_min_point,dense_phase=dense_phase,dense_width=dense_width
    
    
    ;如果不bin
    if (bin eq 0) then begin
      phase_out=(BJD-T0)/P0-floor((BJD-T0)/P0);得到相位均在0-1之间
      flux_out=flux_in
      goto,dne
    endif
    
    
    
    
    ;如果bin
    ;得到原始数据的phase
    phase0=(BJD-T0)/P0-floor((BJD-T0)/P0)  ;得到相位均在0-1之间
    phase1=[phase0-1,phase0,phase0+1] & flux1=[flux_in,flux_in,flux_in]
    phase_out=[] & flux_out=[]
    
    ;得到基本bin的phase
    for i_phase = 0D,  1 + 0.1D/num_point, 1D/num_point do begin
      ind=where( abs(phase1-i_phase) lt 0.5D/num_point , count)
      if (count gt 0) then begin
        flux_out =[flux_out,dadi_mean(flux1[ind])]
            ;flux_out =[flux_out,median(flux1[ind])]
        phase_out=[phase_out,i_phase]
      endif
    endfor    
    
    if (~keyword_set(num_min_point)) then goto,dne ;如果未设置num_min_point，则结束
    if (~keyword_set(dense_phase)) then dense_phase=[]    
    if (~keyword_set(dense_width)) then dense_width=0.03 ;默认宽度
    
    ;去除掉加密区的phase
    dense_phase=[0,1,dense_phase]
    for i = 0L, N_ELEMENTS(dense_phase)-1 do begin
      ind=where(abs(phase_out-dense_phase[i]) gt 0.5*dense_width)
      phase_out=phase_out[ind]
      flux_out = flux_out[ind]
    endfor
    
    
    ;获得加密区bin的phase
    for i_phase = 0D,  1 + 0.1D/num_min_point, 1D/num_min_point do begin
          sepration=abs([0,1,dense_phase]-i_phase) ;获得离极小处的间距
          if (min(sepration) gt 0.5*dense_width) then CONTINUE ;如果不在加密区，则跳过    
      ind=where( abs(phase1-i_phase) lt 0.5D/num_min_point , count)
      if (count gt 0) then begin
        flux_out =[flux_out,dadi_mean(flux1[ind])]
            ;flux_out =[flux_out,median(flux1[ind])]
        phase_out=[phase_out,i_phase]
      endif
    endfor
    
    
    
    
dne: ;结尾标记
end
