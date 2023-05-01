import { LightningElement, api, wire } from 'lwc';
import { getRecord, getFieldValue } from 'lightning/uiRecordApi';
import BILLING_CITY from '@salesforce/schema/Account.BillingCity';
import getWeatherDetails from '@salesforce/apex/weatherWidgetController.getWeatherDetails'
const fields = [BILLING_CITY];

export default class WeatherWidget extends LightningElement {
    @api recordId;

    @wire(getRecord, { recordId: '$recordId', fields })
    account;

    temperature;
    description;
    invalidCity = false;

    connectedCallback(){

        this.fetchData();
   }    

    get city() {
        
        return getFieldValue(this.account.data, BILLING_CITY);
    }
    
    async fetchData(){ 
        //console.log('testing ');
        //console.log('account', this.account);
        while (!this.account.data) {
            // Wait for account data to load
            await new Promise(resolve => setTimeout(resolve, 100));
        }
        const city = this.city;
        console.log('city', city);
        if (city) {
            getWeatherDetails({input:city, recordId: this.recordId}).then(res =>{
                const temperature = res.temperature;
                const description = res.description;
                this.temperature = temperature;
                this.description = description;
                console.log(res.temperature)
                    }).catch(error =>{
                        this.invalidCity = true;
                        console.log(this.invalidCity)
                        console.error(error)
                        })
        }
    }  

}