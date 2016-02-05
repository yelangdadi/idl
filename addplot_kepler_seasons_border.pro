;由plot_kepler_all_seasons_together，目的是在两季数据中画一条竖线，为了查看某些跳变是不是在每段观测的头尾出现。


pro addplot_kepler_seasons_border,p_out=p_out,color=color

border_time=[ $ ;数值来自find_kepler_season_border
  164.9839150340849300D, $
  258.4676366822386600D, $
  349.4955545206685200D, $
  442.2028251401061400D, $
  538.1628118777371100D, $
  629.2965962348971500D, $
  719.5480989892748800D, $
  802.3446720637221000D, $
  905.9266162696149000D, $
 1000.2686454278592000D, $
 1098.3254826792909000D, $
 1182.0215913286956000D, $
 1273.0569086699034000D, $
 1371.3223968776365000D, $
 1471.1364808760482000D, $
 1557.9591151316490000D]+0.5D ;将线从最后一点后移0.5天

for i = 0L, N_ELEMENTS(border_time)-1 do begin
  p=plot([border_time[i],border_time[i]],p_out.yrange,XRANGE=p_out.xrange,/OVERPLOT,COLOR=color) ;IDL学习，注意范围的设置
endfor





end
