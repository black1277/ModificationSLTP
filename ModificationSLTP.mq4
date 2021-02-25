//+------------------------------------------------------------------+
//|                                           Modification_TP_SL.mq4 |
//|                                                           Genkos |
//|                                             http://www.varles.ru |
//+------------------------------------------------------------------+
#property copyright "Genkos"
#property link      "http://www.varles.ru"
#property version   "1.00"
#property strict
int delta=140,// смещение от текущей цены
    Magik=-1; // магик
    int OP=-1;
bool state_sell=true,
state_buy=false,// будет активна кнопка бай
switcher;      // переключатель бай селл
double STOPLEVEL,
mnoj=1.8;      // соотношение СЛ к ТП
string Obj_tp="Line_TP",Obj_sl="Line_SL";
string txtline="";
color clrBr=Gold,// безубыток
colSell = clrLightCoral,// цвета нажатых кнопок
colBuy = clrSkyBlue,
colTP = clrSkyBlue,
colSL = clrLightCoral,
colBrE = clrGold,
backColor=C'236,233,216';
//+------------------------------------------------------------------+
//| Script program start function                                    |
//+------------------------------------------------------------------+
int OnInit()
  {
  if(IsTradeAllowed()==false){NoTrade(true);
  Sleep(7000);
  ExpertRemove();
  }
   STOPLEVEL = MarketInfo(Symbol(),MODE_STOPLEVEL);
   ButtonCreate(0,"OPTIM",0,100,80,100,18,3,"BreakEv");
   ObjectSetString(0,"OPTIM",OBJPROP_TOOLTIP,"Линия безубытка");
   
   ButtonCreate(0,"Submit",0,50,20,50,18,3,"Submit");
   ObjectSetString(0,"Submit",OBJPROP_TOOLTIP,"Выполнить");
   
   ButtonCreate(0,"SL",0,50,40,50,18,3,"SL");
   ObjectSetString(0,"SL",OBJPROP_TOOLTIP,"Линия стоп-лосса");
   
   ButtonCreate(0,"TP",0,50,60,50,18,3,"TP");
   ObjectSetString(0,"TP",OBJPROP_TOOLTIP,"Линия тейкпрофита");
   
   ButtonCreate(0,"Close",0,100,20,50,18,3,"Close");
   ObjectSetString(0,"Close",OBJPROP_TOOLTIP,"Завершить скрипт");
   
   ButtonCreate(0,"SELL",0,100,40,50,18,3,"SELL");
   ObjectSetString(0,"SELL",OBJPROP_TOOLTIP,"Для продаж");
   
   ButtonCreate(0,"BUY",0,100,60,50,18,3,"BUY");
   ObjectSetString(0,"BUY",OBJPROP_TOOLTIP,"Для покупок");
   

   
   ObjectSetInteger(0,"SELL",OBJPROP_STATE,state_sell);
   ObjectSetInteger(0,"BUY",OBJPROP_STATE,state_buy);
   if(state_sell && state_buy) 
     {// только 1 кнопка может быть активна!!!
      Print("Только 1 кнопка может быть активна!!! Или sell, или buy");
      ExpertRemove();
      return(-1);
     }
   if(state_sell) switcher=My_Trig();//установили в фальш, при след вызове вернет true
   else{ My_Trig(); switcher=My_Trig(); }// установили в true, при след вызове вернет false
   return(INIT_SUCCEEDED);
  }
//===================================================================
bool My_Trig()
  {
   static bool trig=true;// селл
   if(trig) trig=false;
   else trig=true;

   return trig;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void OnStart()
  {
//---
   bool  sbm,cls,tp,sl,o_sell,o_buy,brk;

   double priceTP, priceSL;
   while(!IsStopped())
     {
      sbm = ObjectGetInteger(0, "Submit", OBJPROP_STATE);
      cls = ObjectGetInteger(0, "Close", OBJPROP_STATE);
      tp = ObjectGetInteger(0, "TP", OBJPROP_STATE);
      sl = ObjectGetInteger(0, "SL", OBJPROP_STATE);
      o_sell= ObjectGetInteger(0,"SELL",OBJPROP_STATE);
      o_buy = ObjectGetInteger(0,"BUY",OBJPROP_STATE);
      brk= ObjectGetInteger(0,"OPTIM",OBJPROP_STATE);
      if(cls)
        {// прерываем выполнение
         ExpertRemove();
         return;
        }
      if(o_sell && o_buy)
        {// нажаты обе поэтому сверяемся с триггером
         switcher=My_Trig();
         if(!switcher)
           {//делаем активным селл
            ObjectSetInteger(0,"BUY",OBJPROP_STATE,false);
            o_buy=false;
              }else{//активно бай
            ObjectSetInteger(0,"SELL",OBJPROP_STATE,false);
            o_sell=false;
           }
          ObjectDelete(Obj_tp); ObjectDelete(Obj_tp+"n");ObjectDelete(Obj_sl); ObjectDelete(Obj_sl+"n");
        }
      if(!o_sell && !o_buy)
        {//не нажаты обе
          ObjectDelete(Obj_tp); ObjectDelete(Obj_tp+"n");ObjectDelete(Obj_sl); ObjectDelete(Obj_sl+"n");
          ObjectSetInteger(0,"TP",OBJPROP_STATE,0);ObjectSetInteger(0,"SL",OBJPROP_STATE,0);tp = false; sl = false;
        }
      if(o_sell)
        {
         ObjectSetInteger(0,"SELL",OBJPROP_BGCOLOR,colSell);//меняем цвет кнопы на активный
         priceTP=NormalizeDouble(Bid-mnoj*delta*Point,Digits);
         priceSL=NormalizeDouble(Ask+delta*Point,Digits);
           }else{ObjectSetInteger(0,"SELL",OBJPROP_BGCOLOR,backColor);//меняем цвет кнопы на пассивный

        }

      if(o_buy)
        {
         ObjectSetInteger(0,"BUY",OBJPROP_BGCOLOR,colBuy);//меняем цвет кнопы на активный
         priceTP=NormalizeDouble(Ask+mnoj*delta*Point,Digits);
         priceSL=NormalizeDouble(Bid-delta*Point,Digits);
           }else{ObjectSetInteger(0,"BUY",OBJPROP_BGCOLOR,backColor);//меняем цвет кнопы на пассивный

        }
      if(tp)
        {// создаем линию тп
         ObjectSetInteger(0,"TP",OBJPROP_BGCOLOR,colTP);//меняем цвет кнопы на активный
         if(ObjectFind(Obj_tp)==-1) {drawline(Obj_tp,clrBlue,priceTP);drawtext(Obj_tp,priceTP);}
         drawtext(Obj_tp, NormalizeDouble(ObjectGet(Obj_tp,OBJPROP_PRICE1),Digits)); 
         }else {// удаляем линию тп
         ObjectSetInteger(0,"TP",OBJPROP_BGCOLOR,backColor);//меняем цвет кнопы на пассивный
         ObjectDelete(Obj_tp); ObjectDelete(Obj_tp+"n");
        }

      if(sl)
        {// создаем линию sl
         ObjectSetInteger(0,"SL",OBJPROP_BGCOLOR,colSL);//меняем цвет кнопы на активный
         if(ObjectFind(Obj_sl)==-1) {drawline(Obj_sl,clrFireBrick,priceSL);drawtext(Obj_sl,priceSL);}
         drawtext(Obj_sl, NormalizeDouble(ObjectGet(Obj_sl,OBJPROP_PRICE1),Digits)); 
         }else {// удаляем линию sl
         ObjectSetInteger(0,"SL",OBJPROP_BGCOLOR,backColor);//меняем цвет кнопы на пассивный
         ObjectDelete(Obj_sl); ObjectDelete(Obj_sl+"n");
        }
       if(brk)
       {ObjectSetInteger(0,"OPTIM",OBJPROP_BGCOLOR,colBrE);//меняем цвет кнопы на активный
       OP=OP_BUY;
       if(!o_sell && !o_buy) OP=-1;
       if(o_sell) OP=OP_SELL;
          SetHLine(clrBr,"LineofZERO",startZERO(OP));
       }else{ObjectSetInteger(0,"OPTIM",OBJPROP_BGCOLOR,backColor);//меняем цвет кнопы на пассивный
            ObjectDelete("LineofZERO");
       }
       if(sbm){
          //if(IsTradeAllowed()==true){
          //   NoTrade(false);
             ObjectSetInteger(0,"Submit",OBJPROP_BGCOLOR,clrMediumSpringGreen);//меняем цвет кнопы на активный
             if(o_sell) set_for_sell();
             if(o_buy) set_for_buy();
         // } else { NoTrade(true); }       
       }
       else{
       ObjectSetInteger(0,"Submit",OBJPROP_BGCOLOR,backColor);//меняем цвет кнопы на пассивный
//       NoTrade(false);
       }



      //Comment(sbm+"_"+cls+"_"+tp+"_"+sl+"_"+o_sell+"_"+o_buy);
WindowRedraw();
      Sleep(150);
     }

  }
//+------------------------------------------------------------------+
void set_for_sell(){
   double OOP,OSL,OTP,SL,TP;
   int tip;
   double SLsell = NormalizeDouble(ObjectGet(Obj_sl,OBJPROP_PRICE1),Digits);
   double TPsell = NormalizeDouble(ObjectGet(Obj_tp,OBJPROP_PRICE1),Digits);

   RefreshRates();
   for (int i=0; i<OrdersTotal(); i++)
   {    
      if (OrderSelect(i,SELECT_BY_POS,MODE_TRADES))
      { 
         if (OrderSymbol()==Symbol() && (Magik<0 || OrderMagicNumber()==Magik))
         { 
            tip = OrderType(); 
            OOP = NormalizeDouble(OrderOpenPrice(),Digits);
            OSL = NormalizeDouble(OrderStopLoss(),Digits);
            OTP = NormalizeDouble(OrderTakeProfit(),Digits);
            SL=0;TP=0;
            if (tip==OP_SELL)
            {  
               if ((Bid-STOPLEVEL*Point)<TPsell) TP=OTP; else TP=TPsell;
               if (TPsell==0) TP=OTP;

               if ((Ask+STOPLEVEL*Point)>SLsell) SL=OSL; else SL=SLsell;
               if (SLsell==0) SL=OSL;
               
               if (SL != OSL || TP != OTP)
               {  
                  if (!OrderModify(OrderTicket(),OOP,SL,TP,0,White)) Print("Error OrderModify ",GetLastError(), " for order ", OrderTicket());
               }
            } 
         }
      }
   } 
}

void set_for_buy(){
   double OOP,OSL,OTP,SL,TP;
   int tip;
   double SLbuy  = NormalizeDouble(ObjectGet(Obj_sl,OBJPROP_PRICE1),Digits);
   double TPbuy  = NormalizeDouble(ObjectGet(Obj_tp,OBJPROP_PRICE1),Digits);
   RefreshRates();
   for (int i=0; i<OrdersTotal(); i++)
   {    
      if (OrderSelect(i,SELECT_BY_POS,MODE_TRADES))
      { 
         if (OrderSymbol()==Symbol() && (Magik<0 || OrderMagicNumber()==Magik))
         { 
            tip = OrderType(); 
            OOP = NormalizeDouble(OrderOpenPrice(),Digits);
            OSL = NormalizeDouble(OrderStopLoss(),Digits);
            OTP = NormalizeDouble(OrderTakeProfit(),Digits);
            SL=0;TP=0;
            if (tip==OP_BUY)             
            {
               if ((Bid-STOPLEVEL*Point)<SLbuy) SL=OSL; else SL=SLbuy;
               if(SLbuy==0) SL=OSL;
               if ((Ask+STOPLEVEL*Point)>TPbuy) TP=OTP; else TP=TPbuy;
               if(TPbuy==0) TP=OTP;
               if (SL != OSL || TP != OTP)
               {  
                  if (!OrderModify(OrderTicket(),OOP,SL,TP,0,White)) Print("Error OrderModify ",GetLastError(), " for order ", OrderTicket());
               }
            }                                         
            
         }
      }
   } 
}
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {

//--- удалим кнопки
   ButtonDelete(0,"Submit");
   ButtonDelete(0,"Close");
   ButtonDelete(0,"SL");
   ButtonDelete(0,"TP");
   ButtonDelete(0,"SELL");
   ButtonDelete(0,"BUY");
   if(!ObjectGetInteger(0,"OPTIM",OBJPROP_STATE)) ObjectDelete("LineofZERO");
   ButtonDelete(0,"OPTIM");
   ObjectDelete(Obj_tp);
   ObjectDelete(Obj_tp+"n");
   ObjectDelete(Obj_sl);
   ObjectDelete(Obj_sl+"n");
   
   if(ObjectFind(0, "NoTrade")!=-1) ButtonDelete(0,"NoTrade");
   Print(TimeCurrent(),": ",__FUNCTION__," reason code = ",reason);

  }
//+------------------------------------------------------------------+
bool ButtonCreate(const long              chart_ID=0,               // ID графика
                  const string            name="Button",            // имя кнопки
                  const int               sub_window=0,             // номер подокна
                  const int               x=50,                      // координата по оси X
                  const int               y=20,                      // координата по оси Y
                  const int               width=50,                 // ширина кнопки
                  const int               height=18,                // высота кнопки
                  const ENUM_BASE_CORNER  corner=CORNER_RIGHT_LOWER,// угол графика для привязки
                  const string            text="Button",            // текст
                  const string            font="Arial",             // шрифт
                  const int               font_size=10,             // размер шрифта
                  const color             clr=clrBlack,             // цвет текста
                  const color             back_clr=C'236,233,216',  // цвет фона
                  const color             border_clr=clrNONE,       // цвет границы
                  const bool              state=false,              // нажата/отжата
                  const bool              back=false,               // на заднем плане
                  const bool              selection=false,          // выделить для перемещений
                  const bool              hidden=true,              // скрыт в списке объектов
                  const long              z_order=0)                // приоритет на нажатие мышью
  {
//--- сбросим значение ошибки
   ResetLastError();
//--- создадим кнопку
   if(!ObjectCreate(chart_ID,name,OBJ_BUTTON,sub_window,0,0))
     {
      Print(__FUNCTION__,
            ": не удалось создать кнопку! Код ошибки = ",GetLastError());
      return(false);
     }
//--- установим координаты кнопки
   ObjectSetInteger(chart_ID,name,OBJPROP_XDISTANCE,x);
   ObjectSetInteger(chart_ID,name,OBJPROP_YDISTANCE,y);
//--- установим размер кнопки
   ObjectSetInteger(chart_ID,name,OBJPROP_XSIZE,width);
   ObjectSetInteger(chart_ID,name,OBJPROP_YSIZE,height);
//--- установим угол графика, относительно которого будут определяться координаты точки
   ObjectSetInteger(chart_ID,name,OBJPROP_CORNER,corner);
//--- установим текст
   ObjectSetString(chart_ID,name,OBJPROP_TEXT,text);
//--- установим шрифт текста
   ObjectSetString(chart_ID,name,OBJPROP_FONT,font);
//--- установим размер шрифта
   ObjectSetInteger(chart_ID,name,OBJPROP_FONTSIZE,font_size);
//--- установим цвет текста
   ObjectSetInteger(chart_ID,name,OBJPROP_COLOR,clr);
//--- установим цвет фона
   ObjectSetInteger(chart_ID,name,OBJPROP_BGCOLOR,back_clr);
//--- установим цвет границы
   ObjectSetInteger(chart_ID,name,OBJPROP_BORDER_COLOR,border_clr);
//--- отобразим на переднем (false) или заднем (true) плане
   ObjectSetInteger(chart_ID,name,OBJPROP_BACK,back);
//--- включим (true) или отключим (false) режим перемещения кнопки мышью
   ObjectSetInteger(chart_ID,name,OBJPROP_SELECTABLE,selection);
   ObjectSetInteger(chart_ID,name,OBJPROP_SELECTED,selection);
//--- скроем (true) или отобразим (false) имя графического объекта в списке объектов
   ObjectSetInteger(chart_ID,name,OBJPROP_HIDDEN,hidden);
//--- установим приоритет на получение события нажатия мыши на графике
   ObjectSetInteger(chart_ID,name,OBJPROP_ZORDER,z_order);
//--- успешное выполнение
   return(true);
  }
//+------------------------------------------------------------------+
//| Удаляет кнопку                                                   |
//+------------------------------------------------------------------+
bool ButtonDelete(const long   chart_ID=0,    // ID графика
                  const string name="Button") // имя кнопки
  {
//--- сбросим значение ошибки
   ResetLastError();
//--- удалим кнопку
   if(!ObjectDelete(chart_ID,name))
     {
      Print(__FUNCTION__,
            ": не удалось удалить кнопку! Код ошибки = ",GetLastError());
      return(false);
     }
//--- успешное выполнение
   return(true);
  }
//+------------------------------------------------------------------+
//--------------------------------------------------------------------
void drawline(string NameL,color col,double Y1)
  {
   ObjectCreate(NameL,OBJ_HLINE,0,0,Y1,0,0);
   ObjectSet(NameL,OBJPROP_COLOR,col);
   ObjectSet(NameL,OBJPROP_STYLE,STYLE_SOLID);
   ObjectSet(NameL,OBJPROP_WIDTH,1);
   ObjectSet(NameL,OBJPROP_BACK,false);
   ObjectSet(NameL,OBJPROP_RAY,false);
   ObjectSetInteger(0,NameL,OBJPROP_SELECTED,true);
  }
//--------------------------------------------------------------------
void drawtext(string NameL,double Y1)
  {
   string NameLine=StringConcatenate(NameL,"n");
   ObjectDelete(NameLine);
   ObjectCreate(NameLine,OBJ_TEXT,0,Time[WindowFirstVisibleBar()-WindowFirstVisibleBar()/4],Y1,0,0,0,0);
   ObjectSetText(NameLine,NameL,8,"Arial");
   ObjectSet(NameLine,OBJPROP_COLOR,ObjectGet(NameL,OBJPROP_COLOR));
  }
//--------------------------------------------------------------------
  void SetHLine(color cl,string nm="",double p1=0,int st=0,int wd=1) 
  {
   if(nm=="") nm=DoubleToStr(Time[0],0);
   if(p1<=0) p1=Bid;
   if(ObjectFind(nm)<0) ObjectCreate(nm,OBJ_HLINE,0,0,0);
   ObjectSet(nm,OBJPROP_PRICE1,p1);
   ObjectSet(nm,OBJPROP_COLOR,cl);
   ObjectSet(nm,OBJPROP_STYLE,st);
   ObjectSet(nm,OBJPROP_WIDTH,wd);
   ObjectSetString(0,nm,OBJPROP_TOOLTIP,txtline);
  }
//---------------------------------------------------------------------
double startZERO(int Oper=0)
  {
   double BuyLots=0,
   SellLots=0,
   BuyProfit=0,
   SellProfit=0,
   BuyLevel=0,
   SellLevel=0;
   
   int Total=OrdersTotal();
   for(int i=Total-1;i>=0;i--)
     {
      if(OrderSelect(i,SELECT_BY_POS))
        {
         if(OrderSymbol()!=Symbol()&&( OrderMagicNumber()!=Magik || Magik==-1)) continue;
         if(OrderType()==OP_BUY)
           {
            BuyLots=BuyLots+OrderLots();
            BuyProfit=BuyProfit+OrderProfit()+OrderCommission()+OrderSwap();
           }
         if(OrderType()==OP_SELL)
           {
            SellLots=SellLots+OrderLots();
            SellProfit=SellProfit+OrderProfit()+OrderCommission()+OrderSwap();
           }
        }
     }
   double Price=0;
   RefreshRates();
   double TickValue=MarketInfo(Symbol(),MODE_TICKVALUE);
   if(BuyLots>0) BuyLevel=NormalizeDouble(Bid-(BuyProfit/(TickValue*BuyLots)*Point),Digits); else BuyLevel=0;
   if(SellLots>0) SellLevel=NormalizeDouble(Ask+(SellProfit/(TickValue*SellLots)*Point),Digits); else SellLevel=0;
   if((BuyLots-SellLots)>0) Price=NormalizeDouble(Bid-((BuyProfit+SellProfit)/(TickValue*(BuyLots-SellLots))*Point),Digits);
   if((SellLots-BuyLots)>0) Price=NormalizeDouble(Ask+((BuyProfit+SellProfit)/(TickValue*(SellLots-BuyLots))*Point),Digits);
   string Title="Уровень без убытка для "+Symbol();
   string ZeroLevel=" не существует";
   if(Price>0) ZeroLevel=" = "+DoubleToStr(Price,Digits);
   string Buy=" не существует";
   if(BuyLevel>0) Buy=" = "+DoubleToStr(BuyLevel,Digits);
   string Sell=" не существует";
   if(SellLevel>0) Sell=" = "+DoubleToStr(SellLevel,Digits);
   txtline="Уровень б.у."+ZeroLevel+"\nУр. BUY "+Buy+"\nУр. SELL "+Sell;

   if (Price==0)Price=Ask;
   if(Oper==OP_BUY)return(BuyLevel);
   if(Oper==OP_SELL)return(SellLevel); 
   if(Oper==-1)return(Price);
return(Price);
}

void NoTrade(bool ys){
if(ys==true){ // нельзя торговать
//Print("нельзя торговать");
   if(ObjectFind(0, "NoTrade")==-1){
//   Print("не найден");
   ButtonCreate(0,"NoTrade",0,200,200,200,36,3,"Автоторговля запрещена!");
   ObjectSetInteger(0,"NoTrade",OBJPROP_BGCOLOR,colSL);//меняем цвет кнопы на активный
   }
} else { // можно, удаляем сообщение
   if(ObjectFind(0, "NoTrade")!=-1){
      ButtonDelete(0,"NoTrade");
      }
}
}
