const app = Vue.createApp({
    data() {
        return {
            listener: () => {},
            selection: '0',
            maxValue: '0',
            isOpen: false,
        }
    },
    watch: {
        selection() {
            this.previewSelection()
        },
    },
    methods: {
        async previewSelection() {
            const requestOptions = {
                method: "POST",
                headers: { "Content-Type": "application/json; charset=UTF-8", accept: 'application/json' },
                body: JSON.stringify({ selected: this.selection })
            };
            const response = await fetch(`https://${GetParentResourceName()}/previewSkin`, requestOptions);
            if (!response.ok) {
                throw new Error(`Error! status: ${response.status}`);
            }
        },
        async exitUI() {
            this.isOpen = false
            const requestOptions = {
                method: "POST",
                headers: { "Content-Type": "application/json" },
                body: JSON.stringify({ type: "exit" })
            };
            const response = await fetch(`https://${GetParentResourceName()}/closeUI`, requestOptions);
        },
        async confirmChange() {
            this.isOpen = false
            const requestOptions = {
                method: "POST",
                headers: { "Content-Type": "application/json" },
                body: JSON.stringify({ type: "confirm" })
            };
            const response = await fetch(`https://${GetParentResourceName()}/closeUI`, requestOptions);
        }
    },
    mounted() {
        this.listener = (event) => {         
            if (event.data.type === 'getskins') {
                this.maxValue = event.data.maxSkins
            }
            else if (event.data.type == 'open') {
                this.isOpen = true
            }
        }
        window.addEventListener('message', this.listener)
    },
    destroyed() {
        window.removeEventListener('message', this.listener)
    }
})

app.mount('#app')