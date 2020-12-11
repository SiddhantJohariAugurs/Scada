<template>
    <v-app ref="app">
        <v-expansion-panels v-model="expanded" multiple hover @change="toggleCollapsed">
            <v-expansion-panel>
                <!-- Collapsible title apply, cancel and view settings controls -->
                <v-expansion-panel-header>
                    <v-row no-gutters align="center">
                        <v-col cols="auto">
                            <v-icon small>mdi-calendar</v-icon>{{ settings.calendarName }}
                        </v-col>   
                        <v-col cols="auto">         
                            <v-container v-if="((editEnabled && showSettings) || (!settings.viewOnly && !readOnly)) && (expanded.length>0 || changed)">
                                <v-btn xSmall color="primary" class="mr-2" @click.stop="apply" :disabled="!changed || busy">
                                    {{$t('calendar.apply')}}
                                    <v-icon v-if="!busy" right>mdi-check</v-icon><v-icon v-if="busy" right>mdi-alarm-check</v-icon>
                                </v-btn>
                                <v-btn xSmall color="error" class="mr-2" @click.stop="cancel" :disabled="!changed || busy">
                                    {{$t('calendar.cancel')}}
                                    <v-icon v-if="!busy" right>mdi-window-close</v-icon><v-icon v-if="busy" right>mdi-alarm-check</v-icon>
                                </v-btn>
                            </v-container>                       
                        </v-col>
                        <v-col cols="auto"> 
                            <v-btn icon @click.stop="toggleSettings" v-if="editEnabled"> 
                                <v-icon small>mdi-cog</v-icon>
                            </v-btn>
                        </v-col>
                    </v-row>
                </v-expansion-panel-header>
                <!-- Calendar month/day selection control -->
                <v-expansion-panel-content :id="'c'+componentId+'-calendar-body'">
                    <v-toolbar flat color="white" dense v-if="!error && !showSettings">
                        <v-btn outlined class="mr-4" color="grey darken-2" @click="setToday">
                            {{$t('calendar.today')}}
                        </v-btn>
                        <v-btn fab text small color="grey darken-2" @click="$refs.calendar.prev()">
                            <v-icon small>mdi-chevron-left</v-icon>
                        </v-btn>
                        <v-btn fab text small color="grey darken-2" @click="$refs.calendar.next()">
                            <v-icon small>mdi-chevron-right</v-icon>
                        </v-btn>
                        <v-toolbar-title class="mr-4">
                            {{ getMonth() }}
                        </v-toolbar-title>
                        <v-menu :attach="'#c'+componentId+'-calendar-body'" v-if="showCalendarTypes">
                            <template v-slot:activator="{ on, attrs }">
                                <v-btn outlined color="grey darken-2" v-bind="attrs" v-on="on">
                                    <span>{{ calendarTypeOptions[settings.calendarType] }}</span>
                                    <v-icon right>mdi-menu-down</v-icon>
                                </v-btn>
                            </template>
                            <v-list>
                                <v-list-item @click="changeType(index)"  v-for="(item, index) in calendarTypeOptions" :key="index">
                                    <v-list-item-title>{{item}}</v-list-item-title>
                                </v-list-item>
                            </v-list>
                        </v-menu>
                    </v-toolbar>
                    <!-- Main calendar contents -->
                    <v-main>
                        <!-- Settings form -->
                        <v-form v-if="showSettings"
                            ref="form"
                            >                      
                            <v-select
                                :attach="'#c'+componentId+'-calendar-body'"
                                v-model="settings.dataSourceId"
                                :items="datasources"
                                :rules="[v => !!v, v => v !== $t('calendar.datasourceRequired')]"
                                :label="$t('calendar.datasource')"
                                @change="updateChanged"
                            ></v-select>
                            <v-text-field
                                v-model="settings.calendarName"
                                :label="$t('calendar.name')"
                                :rules="[v => v!=='']"
                                @input="updateChanged"
                            ></v-text-field>
                            <v-text-field
                                v-model="settings.calendarPrefix"
                                :label="$t('calendar.calendarPrefix')"
                                :hint="$t('calendar.prefix')"
                                :rules="[v => v!=='']"
                                @input="updateChanged"
                            ></v-text-field>
                            <v-row>
                                <v-col cols="4">
                                    <v-menu :attach="'#c'+componentId+'-calendar-body'">
                                        <template v-slot:activator="{ on, attrs }">
                                            <v-btn outlined color="grey darken-2" v-bind="attrs" v-on="on">
                                                <span>{{ calendarTypeOptions[settings.calendarType] }}</span>
                                                <v-icon right>mdi-menu-down</v-icon>
                                            </v-btn>
                                        </template>
                                        <v-list>
                                            <v-list-item @change="updateChanged" @click="settings.calendarType = index"  v-for="(item, index) in calendarTypeOptions" :key="index">
                                                <v-list-item-title>{{item}}</v-list-item-title>
                                            </v-list-item>
                                        </v-list>
                                    </v-menu>
                                </v-col>
                                <v-col cols="auto">
                                  <v-label light class="text-subtitle-2">{{$t("calendar.type")}}</v-label>
                                </v-col>
                            </v-row>
                            <v-checkbox
                                v-model="settings.viewOnly"
                                :label="$t('calendar.viewOnly')"
                                @change="updateChanged"
                            ></v-checkbox>
                            <v-checkbox
                                v-model="settings.showCalendarTypes"
                                :label="$t('calendar.showCalendarTypes')"
                                @change="updateChanged"
                            ></v-checkbox>
                            <v-checkbox
                                v-model="settings.globalCalendar"
                                :label="$t('calendar.globalCalendar')"
                                @change="updateChanged"
                            ></v-checkbox>
                            <v-checkbox
                                v-if="!settings.globalCalendar"
                                v-model="settings.showMaster"
                                :label="$t('calendar.showMaster')"
                                @change="updateChanged"
                            ></v-checkbox>
                            <v-text-field
                                v-if="!settings.globalCalendar && settings.showMaster"
                                v-model="settings.masterPrefix"
                                :label="$t('calendar.masterPrefix')"
                                :placeholder="$t('calendar.prefix')"
                                :rules="[v => v!=='']"
                                @input="updateChanged"
                            ></v-text-field>
                            <v-checkbox
                                v-model="settings.collapsed"
                                :label="$t('calendar.collapsed')"
                                @change="updateChanged"
                            ></v-checkbox>
                            <v-btn small color="error" class="mr-2" @click.stop="remove()">
                                {{$t('calendar.remove')}}
                                <v-icon right>mdi-delete</v-icon>
                            </v-btn>
                        </v-form>
                        <!-- Calendar -->
                        <v-calendar v-else-if="!error" :weekdays="weekday" ref="calendar" color="primary" :type="settings.calendarType" :events="events"
                            event-color="#FFFFFF00" v-model="currentDate" @click:event="eventClick" :event-timed="getTimed"
                            :event-ripple=false @mousedown:event="startDrag" @mousedown:time="startTime" @mousemove:time="mouseMove" @mouseup:time="endDrag"
                            @mouseleave.native="cancelDrag" title="" @click:day="addDayEvent" @click:date="addOneEvent" style="height: 480px">
                            <template #day-body="{ date, week }">
                                <div class="v-current-time" :class="{ first: date === week[0].date }" :style="{ top: nowY() }">
                                </div>
                            </template>
                            <template #event="{ event }">
                                <v-tooltip absolute :attach="'#c'+componentId+'-calendar-body'" >
                                    <template v-slot:activator="{ on, attrs }" v-if="settings.calendarType!=='month'">
                                        <v-card onselectstart="return false" @click="showMenu(event,$event)" outlined v-bind="attrs" v-on="on" :style="{background: getEventColor(event)}" style="height: 100%" 
                                            class="d-flex flex-column align-items-stretch">

                                            <span class="text-small ma-0 pa-1"  v-bind:class="{ 'calendar-text-disabled': checkEventDisabled(event)}" >{{getHint(event)}}</span>
                                            <div class="v-event-drag-bottom d-flex justify-center"
                                                @mousedown.stop="extendBottom(event, $event)" v-if="!checkEventDisabled(event) && settings.calendarType !== 'month'">
                                                <v-icon dark class="elevation-2">mdi-drag-horizontal</v-icon>
                                            </div>
                                        </v-card>
                                    </template>
                                    <template v-slot:activator="{ on, attrs }" v-else>  
                                        <v-card v-bind="attrs" @click="showMenu(event,$event)"
                                            v-on="on" outlined :style="{background: getEventColor(event)}" style="height: 100%"
                                            class="d-flex flex-column align-items-stretch">
                                            {{event.master ? "(G.C.)": ""}}
                                        </v-card>
                                    </template>             
                                    <span>{{getHint(event)}}</span>
                                </v-tooltip>
                                <v-menu v-model="menuVisible" auto>                          
                                    <v-list dense>
                                        <v-subheader>{{$t("calendar.shows")}}</v-subheader>
                                        <v-list-item ripple  @click="deleteEvent(selectedEvent,$event)">
                                            <v-list-item-icon>
                                                <v-icon>mdi-delete</v-icon>
                                            </v-list-item-icon>
                                            <v-list-item-title>{{ $t("calendar.remove")}}</v-list-item-title>
                                        </v-list-item>
                                        <v-list-item-group color="primary" @change="selectShow" v-if="selectedEvent">
                                            <v-list-item v-for="(item) in calendarValues.shows" :key="item.value" ripple>
                                                <v-list-item-icon>
                                                    <div :style="{background: getEventColor(item)}" style="width: 20px; border-radius: 3px"></div>
                                                </v-list-item-icon>
                                                <v-list-item-title>{{ item.text }}</v-list-item-title>
                                            </v-list-item>
                                        </v-list-item-group>
                                    </v-list>
                                </v-menu> 
                            </template>      
                        </v-calendar>
                        <br>
                        <v-alert v-if="error" type="error">
                            {{error}}
                        </v-alert>
                    </v-main>
                </v-expansion-panel-content>
            </v-expansion-panel>
        </v-expansion-panels>
    </v-app>
</template>
<script>
    const ROUND_TIME_MINUTES = 15;
    const START_PREFIX = '-start-';
    const END_PREFIX = '-end-';
    const VALUE_PREFIX = '-value-';
    const DEFAULT_SHOW = "DEFAULT";

    import axios from "axios";

    export default {
        name: 'CalendarComponent',
        props:{
            calendarName: {
                type: String,
                default: 'Calendar'
            },
            componentId: {
                type: Number,
                required: false
            },
            calendarPrefix: {
                type: String,
                default: 'schedule'
            },
            collapsed: {
                type: Boolean,
                default: false
            },
            viewOnly: {
                type: Boolean,
                default: true
            },
            showMaster: {
                type: Boolean,
                default: false
            },
            showCalendarTypes: {
                type: Boolean,
                default: true
            },
            globalCalendar: {
                type: Boolean,
                default: false
            },
            masterPrefix: {
                type: String,
                default: 'master'
            },
            dataSourceId: {
                type: Number
            },
            calendarValues: {
                type: Object,
                required: true
            },
            calendarType: {
                type: String,
                default: "month"
            }
        },
        async beforeMount() {
            try {
                this.currentSettings = this.deepCopyObject(this.$props);
                this.settings = this.deepCopyObject(this.$props);
                this.editEnabled = window.location.pathname.includes('view_edit');
                this.expanded = this.settings.collapsed ? [] : [0];   
                this.server = window.location.origin;
                if (process.env.NODE_ENV === 'development') {
                    //MOCK_SCADA = "https://fbbc38b4-f49a-44e4-b02d-5b3207f7a00a.mock.pstmn.io";
                    this.server  = 'http://localhost:8080';
                    await axios.get(`${this.server}/api/auth/admin/admin`, {withCredentials: true});
                } else {
                    this.server += location.pathname.substr(0,location.pathname.lastIndexOf('/'));
                } 
                var datasources = await axios.get(`${this.server}/api/datasource/getAll`, {withCredentials: true});
                this.datasources = this.datasources.concat(datasources.data.map(d => {return {text: d.name, value: d.id, permission: d.permission}}));
                var ds = this.datasources.find(d => d.value === this.settings.dataSourceId);
                if (!ds && this.datasources.length > 0) {
                    ds = this.datasources[0];
                    this.settings.dataSourceId = this.datasources[0].value; 
                    this.changed = true; 
                }
                if (ds) {
                    this.readOnly = ds.permission < 2; 
                    await this.getSchedule();   
                }
                if (this.events.length>0) {
                   this.selectedEvent = this.events[0]; 
                }
                  
            } catch(e) {
                this.handleError(e);
            }
        },
        mounted() {
            this.toggleCollapsed();  
        },
        beforeUpdate() {
            if (!this.timeInterval) {
               this.scrollToTime(); 
               this.updateTimes();
            } 
        },
        data() {
            return {
                currentDate: '',
                expanded: [0],
                datasources: [],
                currentEvents: [],
                events: [], // {start: timestampSeconds, end: timestampSeconds, value: Number}
                calendarTypeOptions: {
                    '4day': this.$i18n.t('calendar.4days'),
                    day: this.$i18n.t('calendar.day'),
                    month: this.$i18n.t('calendar.month'),
                    week: this.$i18n.t('calendar.week')
                },
                changed: false,
                showSettings: false,
                selectedEvent: undefined,
                editEnabled: true,
                weekday: [0, 1, 2, 3, 4, 5, 6],
                disabled: false,
                busy: false,
                error: false,
                server: "",
                status: "",
                menuVisible: false,
                settings: {},
                currentSettings: {},
                readOnly: true,
                dragEvent: null,
                dragStart: null,
                createEvent: null,
                createStart: null,
                extendOriginal: null, 
                rendered: false
            }
        },
        methods: {
            deepCopyObject(object) {
                return JSON.parse(JSON.stringify(object));
            },
            changeType(index) {
                this.settings.calendarType = index;
                this.scrollToTime();
            },
            /**
             * Returns the current month to display in calendar header
             */
            getMonth() {
                if (this.$refs.calendar)
                    return this.$refs.calendar.title;
                return '';
            },
            showMenu(event,htmlEvent) {
                this.selectedEvent = event;
                if (this.checkEventDisabled(event) || this.dragging) {
                    htmlEvent.stopPropagation();
                    return;
                }

                this.menuVisible = true;
                htmlEvent.stopPropagation();
            },
            eventClick(event) {
               event.nativeEvent.stopPropagation();
            },
            handleError(e, errorMessage) {
                console.log(e);
                this.busy = false;
                if (e.response && errorMessage) 
                    this.error = errorMessage;
                // The request was made and the server responded with a status code
                else if (e.response) {
                    if (e.response.data)
                        this.error = this.$t('calendar.error', {status: `${e.response.data.localizedMessage} (code: ${e.response.status})`, server: this.server});
                    else
                        this.error = this.$t('calendar.error', {status: `(code: ${e.response.status})`, server: this.server});
                } else if (e.request) 
                // The request was made but no response was received
                    this.error = this.$t('calendar.error', {status: `(Connection Refused)`, server: this.server});
                else
                // Something happened in setting up the request that triggered an Error
                    this.error = this.$t('calendar.error', {status: `(code: ${e.message})`, server: this.server});
            },
            handleDnD(event) {
                event.stopPropagation();
            },
            nowY() {
                return this.$refs.calendar ? this.$refs.calendar.$children.find(c => c.timeToY).timeToY(this.$refs.calendar.times.now) + 'px' : '-10px'
            },
            toggleCollapsed() {
                var div = document.querySelector("#c"+ this.componentId);
                if (div) {
                    if (!this.left) {
                        this.left = div.style.left;
                        this.top = div.style.top;
                    }

                    if (this.expanded.length>0) {
                        this.left = div.style.left;
                        this.top = div.style.top;
                        div.classList.remove('calendar-collapsed');
                        div.classList.add('calendar-expanded');
                    
                        this.$refs.app.$el.addEventListener('mousedown', this.handleDnD); 
                    } else {
                        div.style.left = this.left;
                        div.style.top = this.top; 
                        div.classList.remove('calendar-expanded');
                        div.classList.add('calendar-collapsed');
                        if (this.editEnabled && window.addDnD) {
                            window.addDnD('c'+this.componentId); 
                        } 

                        this.$refs.app.$el.removeEventListener('mousedown', this.handleDnD); 
                    }
                }  
            },
            addDayEvent(event) {
                if (this.checkDisabled() || event.past) return;
                var date = Date.parse(event.date+'T00:00:00');
                var endTime = Date.parse(event.date+"T23:59:59");
                this.events.push({start: date, end: endTime, value: this.settings.calendarValues.shows.find(s => s.text === DEFAULT_SHOW).value});
                this.changed = true;
            },
            addOneEvent(event) {
                if (this.checkDisabled() || event.past || this.events.find(e => {
                    return !e.readOnly && e.start >= Date.parse(event.date+'T00:00:00') && e.end <= Date.parse(event.date+'T23:59:59');
                })) return;
                var date = Date.parse(event.date+'T00:00:00');
                var endTime = Date.parse(event.date+"T23:59:59");
                this.events.push({start: date, end: endTime, value: this.settings.calendarValues.shows.find(s => s.text === DEFAULT_SHOW).value});
                this.changed = true;
            },
            selectShow(index) {
                this.selectedEvent.value = this.settings.calendarValues.shows[index].value;
                this.updateChanged();
            },
            /**
             * Shows apply/cancel for changes
             */
            updateChanged() {
                this.changed = true;
            },
            /**
             * Removes the calendar from the view
             */
            remove() {
                if (window.deleteViewComponent) window.deleteViewComponent(this.componentId);
                this.$el.remove();
            },
            checkEventDisabled(event) {
                return this.checkDisabled() || event.viewOnly
            },
            /**
             * Check if the calendar is in view or read only modes viewOnly is user definable readOnly is set by user permission.
             */
            checkDisabled() {
                this.disabled = this.readOnly || this.settings.viewOnly || this.busy; 
                return this.disabled;
            },
            /**
             * Toggle between Calendar and Settings.
             */
            toggleSettings() {
                this.showSettings = !this.showSettings;
                this.expanded = [0];
                this.toggleCollapsed();
            },
            /** 
             * This callback is called after saving the settings.
             */
            saveSettingsSuccess() {
                this.currentEvents = this.deepCopyObject(this.events);
                this.currentSettings = this.deepCopyObject(this.settings);
                this.changed = false;
                this.busy = false;
                this.showSettings = false;
                this.getSchedule().then();
            },
            async getSchedule(dataSourceId, prefix) {
                try {
                    var dsid = dataSourceId || this.settings.dataSourceId;
                    if (dsid === this.settings.dataSourceId && (!prefix || ( prefix === this.settings.calendarPrefix))) {
                        var schedule = await axios.get(`${this.server}/api/point_value/getSchedule`, {
                            params: {
                                dataSourceId: this.settings.dataSourceId,
                                startPrefix: this.settings.calendarPrefix + START_PREFIX,
                                endPrefix: this.settings.calendarPrefix + END_PREFIX,
                                valuePrefix: this.settings.calendarPrefix + VALUE_PREFIX
                            },
                            withCredentials: true});

                        if (dataSourceId) {
                            this.currentEvents = this.currentEvents.filter(e => e.master);
                            this.events = this.events.filter(e => e.master);
                        }

                        this.currentEvents = this.currentEvents.concat(this.deepCopyObject(schedule.data));
                        this.events = this.events.concat(this.deepCopyObject(schedule.data));
                    }
                    if (!this.globalCalendar && this.showMaster && (!dataSourceId || dataSourceId === -1) && (!prefix || ( prefix === this.settings.masterPrefix))) {
                        var masterSchedule = await axios.get(`${this.server}/api/point_value/getSchedule`, {
                            params: {
                                dataSourceId: this.settings.dataSourceId,
                                startPrefix: this.settings.masterPrefix + START_PREFIX,
                                endPrefix: this.settings.masterPrefix + END_PREFIX,
                                valuePrefix: this.settings.masterPrefix + VALUE_PREFIX
                            },
                            withCredentials: true});
                        masterSchedule.data = masterSchedule.data.map((e) => {return {...e, viewOnly: true, master: true}});
                        this.currentEvents = this.currentEvents.filter(e => !e.master);
                        this.events = this.events.filter(e => !e.master);
                        this.currentEvents = this.currentEvents.concat(this.deepCopyObject(masterSchedule.data));
                        this.events = this.events.concat(this.deepCopyObject(masterSchedule.data));
                    }         
                } catch(e) {
                    this.handleError(e, this.$t("calendar.schedule.error"));
                    throw(e);
                }
            },
            /**
             * Apply/Save changes for calendar or settings
             */
            apply() {
                this.error = '';

                if (this.showSettings) {
                    if (!this.$refs.form.validate()) {
                        this.error = this.$i18n.t("calendar.invalidSettings");
                        return;
                    }
                    this.busy = true;
                    if (window.staticEditor) {
                        window.staticEditor.componentId = this.componentId;
                        window.staticEditor.component = {defName: 'calendar'};
                        var lSettings = this.deepCopyObject(this.settings);
                        delete lSettings.calendarValues;
                        window.staticEditor.save(JSON.stringify(lSettings), this.saveSettingsSuccess);
                    } else {
                        this.saveSettingsSuccess();
                    }
                } else {
                    this.busy = true;
                    var dsid = (this.settings.globalCalendar) ? -1 : this.settings.dataSourceId;
                    this.events = this.events.filter(e => {
                            return e.master || e.end > new Date().setDate(new Date().getDate()-1)});
                    axios.post(`${this.server}/api/point_value/setSchedule`, 
                        this.events.filter(e => !e.master).map(e => {
                            return {start: e.start / 1000, end: e.end / 1000, value: e.value}
                        }), {
                            params: {
                                dataSourceId: dsid,
                                startPrefix: this.settings.calendarPrefix + START_PREFIX,
                                endPrefix: this.settings.calendarPrefix + END_PREFIX,
                                valuePrefix: this.settings.calendarPrefix + VALUE_PREFIX
                            },
                            withCredentials: true}).then(() => {
                                this.currentEvents = this.deepCopyObject(this.events);
                                this.changed = false;
                                this.busy = false;
                                this.refreshOtherCalenders(dsid);
                            }).catch((e) => this.handleError(e));
                }
            },
            refreshOtherCalenders(dataSourceId) {
                window.vueComponents.forEach(c => {
                    if (c._vnode.tag.includes('CalendarComponent') && c.$children[0]._uid != this._uid && !c.$children[0].changed) {
                        c.$children[0].getSchedule(dataSourceId);
                    }
                });
            },
            /**
             * Cancel changes add support for settings
             */
            cancel() {
                this.events = this.deepCopyObject(this.currentEvents);
                this.settings = this.deepCopyObject(this.currentSettings);
                this.changed = false;
                this.error = "";
            },
            /**
             * Set calendar to today, should only be called after this.$refs.calendar exists which occurs after first render.
             */
            scrollToTime() {
                if (!this.$refs.calendar) return;
                this.$refs.calendar.scrollToTime(this.$refs.calendar.times.now);
            },
            /**
             * Hint text shown in the Calendar schedule
             */
            getHint(event) {
                var start = new Date(event.start);
                var end = new Date(event.end);
                var show = this.findShow(event);
                var hint = `${show.text}, ${start.toLocaleString(window.navigator.language, { weekday: 'short' })} ${start.toLocaleTimeString().replace(/:00$/, '')} ` + this.$i18n.t('calendar.to') + ` ${end.toLocaleString(window.navigator.language, { weekday: 'short' })} ${end.toLocaleTimeString().replace(/:00$/, '')}`;
                hint += (event.master) ? this.$i18n.t('calendar.from', {calendar: this.settings.masterPrefix}) : '';
                return hint;
            },
            /** 
             * Update the red bar time every minute, should only be called after this.$refs.calendar exists which occurs after first render.
             */
            updateTimes() {
                if (!this.$refs.calendar || this.timeInterval) return
                this.$refs.calendar.updateTimes();
                this.timeInterval = setInterval(this.$refs.calendar.updateTimes, 60 * 1000);
            },
            /**
             * Called when a user starts to drag an existing event
             */
            startDrag({ event }) {
                if (this.checkEventDisabled(event)) {
                    return false;
                }
                if (event) {
                    this.dragEvent = event
                    this.dragTime = null
                    this.extendOriginal = null
                }
            },
            /**
             * Called on creation of event
             */
            startTime(tms) {
                if (this.checkDisabled()) return false;
                const mouse = this.toTime(tms)

                if (this.dragEvent && this.dragTime === null) {
                    const start = this.dragEvent.start

                    this.dragTime = mouse - start
                } else {
                    this.createStart = this.roundTime(mouse, true)
                    this.createEvent = {
                        value: 0,
                        start: this.createStart,
                        end: this.createStart + (60*60*1000), // 1h
                    }

                    this.events.push(this.createEvent)
                }
            },
            extendBottom(event, htmlEvent) {
                this.createEvent = event
                this.createStart = event.start
                this.extendOriginal = event.end
            },
            mouseMove(event) {
                const mouse = this.toTime(event)

                if (this.dragEvent && this.dragTime !== null) {
                    const start = this.dragEvent.start
                    const end = this.dragEvent.end
                    const duration = end - start
                    const newStartTime = mouse - this.dragTime
                    const newStart = this.roundTime(newStartTime, false)
                    const newEnd = newStart + duration

                    this.dragEvent.start = newStart
                    this.dragEvent.end = newEnd
                    this.dragging = true;
                } else if (this.createEvent && this.createStart !== null) {
                    const min = Math.min(this.roundTime(mouse,true), this.createStart)
                    const max = Math.max(this.roundTime(mouse,false), this.createStart)
                    this.createEvent.start = min
                    this.createEvent.end = max
                }
            },
            endDrag() {
                this.dragTime = null
                this.dragEvent = null
                this.createEvent = null
                this.createStart = null
                this.extendOriginal = null
                this.changed = true;
                this.dragging = false;
            },
            isCollapsed() {
                return this.expanded.length===0;
            },
            /**
             * Delete event and set status to changed
             */
            deleteEvent(event, htmlEvent) {
                this.events = this.events.filter(e => e != event);
                this.changed = true;
                this.menuVisible = false;
            //    htmlEvent.stopPropagation();
            },
            cancelDrag() {
                if (this.createEvent) {
                    if (this.extendOriginal) {
                        this.createEvent.end = this.extendOriginal
                    } else {
                        const i = this.events.indexOf(this.createEvent)
                        if (i !== -1) {
                            this.events.splice(i, 1)
                        }
                    }
                }

                this.createEvent = null
                this.createStart = null
                this.dragTime = null
                this.dragEvent = null
                this.dragging = false;
            },
            roundTime(selectedTime, down) {
                const roundDownTime = ROUND_TIME_MINUTES * 60 * 1000 // round to 15 minutes

                var date = new Date(selectedTime)
                if (!down && date.getHours() == 23 && date.getMinutes() >= 45) 
                  return Math.floor(selectedTime + (roundDownTime - (selectedTime % roundDownTime)) - 1);
                
                var round = down
                    ? selectedTime - selectedTime % roundDownTime
                    : selectedTime + (roundDownTime - (selectedTime % roundDownTime));

                return round;
            },
            /**
             * Convert Calendar time object to Date
             */
            toTime(tms) {
                return new Date(tms.year, tms.month - 1, tms.day, tms.hour, tms.minute).getTime()
            },
            /**
             * Does the calendar support time selection
             */
            getTimed() {
                return true
            },
            saturateChannel(channel, saturation) {
                var v = Math.round(channel * saturation);
                v = (v > 0xFF) ? 0xFF : (v < 0) ? 0 : v;
                return v;
            },
            getRGBAColor(hexColor, alpha, saturation) {
                const rgb = parseInt(hexColor, 16)
                const r = this.saturateChannel((rgb >> 24) & 0xFF, saturation)
                const g = this.saturateChannel((rgb >> 16) & 0xFF, saturation)
                const b = this.saturateChannel((rgb >> 8) & 0xFF, saturation)
                return `rgba(${r}, ${g}, ${b}, ${alpha})`;
            },
            findShow(event) {
                var show = this.calendarValues.shows.find(s => s.value === event.value);
                if (!show) show =this.calendarValues.shows.find(s => s.text === DEFAULT_SHOW);
                return show;
            },
            getAlphaColor(event, alpha, saturation) {
                var show = this.findShow(event);
                if (show.sequence.length===1) {
                    return this.getRGBAColor(this.calendarValues.colors[show.sequence[0]], alpha, saturation)
                }
                var gradient = "linear-gradient(to right,";
                show.sequence.forEach((color) => {
                    gradient += this.getRGBAColor(this.calendarValues.colors[color], alpha, saturation)+',';
                })
                return gradient.substring(0,gradient.length-1) + ")";
            },
            getEventColor(event) {
                var alpha = 0.5;
                var saturation = 0.9;
                if (this.createEvent) alpha  += 0.3;
                return this.getAlphaColor(event, alpha, saturation)
            },
            /**
             * Set the calender to today
             */
            setToday() {
                this.currentDate = '';
            }
        }
    }
</script>
<style lang="scss">
    .calendar .v-event {
       width: 100% !important;
       flex: 1;
    }
    .calendar .v-event-timed-container {
        margin-right: 0px !important;
    }
    .calendar .v-input {
        font-size: 1em;
        margin-top: 0px;
    }
    .calendar .v-label {
        font-size: 1em;
    }
    .calendar .v-messages {
        min-height: auto;
    }
    .calendar .v-text-field__details {
        min-height: auto;
    }
    #app input {
        font-size: 1em !important;
    }
    .calendar .v-expansion-panel-header {
        padding: 0px 4px 0px 4px;
        font-size: 1rem !important;
    }
    .calendar .v-event-drag-bottom {
        position: absolute;
        left: 0;
        right: 0;
        bottom: 4px;
        height: 4px;
        cursor: ns-resize;

        &::after {
            position: absolute;
            left: 50%;
            height: 4px;
            border-top: 1px solid white;
            border-bottom: 1px solid white;
            width: 16px;
            margin-left: -8px;
            opacity: 0.8;
        }

        &:hover::after {
            display: block;
        }
    }
    #app > div.v-application--wrap {
        min-height: auto !important;
        z-index: 7;
    }
    .calendar .v-calendar-daily__scroll-area {
        overflow: auto;
    }
    .calendar .v-calendar-daily__head {
        margin-right: 15px;
    }
    .calendar .v-btn--fab.v-size--default {
        height: 100%;
        width: 100%;
        border-radius: 4px !important; 
    }
    .calendar .calendar-expanded {
        height: 50vh;
    }
    .calendar .calendar-collapsed {
        width: fit-content;
    }
    .calendar .calendar-text-disabled {
        color: rgba(0, 0, 0, 0.38);
    }
    .calendar .v-main__wrap {
        height: auto;
    }
    .calendar .v-calendar-weekly {
        height: auto;
    }
    .calendar .v-calendar-weekly__day {
        display: flex;
        flex-direction: column;
    }
    .calendar .v-current-time {
        height: 2px;
        background-color: #ea4335;
        position: absolute;
        left: -1px;
        right: 0;
        pointer-events: none;

        &.first::before {
            content: '';
            position: absolute;
            background-color: #ea4335;
            width: 12px;
            height: 12px;
            border-radius: 50%;
            margin-top: -5px;
            margin-left: -6.5px;
        }
    }
</style>