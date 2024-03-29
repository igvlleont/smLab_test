
#Область ОбработчикиКомандФормы

&НаКлиенте
Процедура СоздатьРеализациюТоваровИУслуг(Команда)
	
	СписокНоменклатуры = Новый Массив;
	
	Для Каждого СтрокаСписка Из Элементы.Список.ВыделенныеСтроки Цикл
		Если Не ТипЗнч(СтрокаСписка) = Тип("СправочникСсылка.Номенклатура") Тогда
			Продолжить;
		КонецЕсли;
			
		СписокНоменклатуры.Добавить(СтрокаСписка);	
	КонецЦикла;	
	
	ДанныеЗаполнения = Новый Структура("Номенклатура", СписокНоменклатуры);
	
	ПараметрыОткрытия = Новый Структура("ЗначенияЗаполнения", ДанныеЗаполнения);
	ОткрытьФорму("Документ.РеализацияТоваровИУслуг.Форма.ФормаДокумента", ПараметрыОткрытия);
	
КонецПроцедуры

#КонецОбласти
